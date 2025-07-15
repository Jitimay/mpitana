import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isar/isar.dart';
import '../../screens/offerRide/models/ride_offer.dart';
import '../../common/database/isar_db.dart';
import 'ride_event.dart';
import 'ride_state.dart';

class RideBloc extends Bloc<RideEvent, RideState> {
  Isar? _isar;

  RideBloc() : super(RideInitial()) {
    _initializeIsar();
    on<LoadRidesEvent>(_onLoadRides);
    on<CreateRideOfferEvent>(_onCreateRideOffer);
    on<SearchRidesEvent>(_onSearchRides);
    on<BookRideEvent>(_onBookRide);
    on<CancelRideEvent>(_onCancelRide);
  }

  Future<void> _initializeIsar() async {
    _isar = await IsarDb.instance;
  }

  Future<void> _onLoadRides(LoadRidesEvent event, Emitter<RideState> emit) async {
    emit(RideLoading());
    
    try {
      if (_isar == null) {
        _isar = await IsarDb.instance;
      }
      
      final rides = await _isar!.rideOffers.where().findAll();
      emit(RideLoaded(rides: rides));
    } catch (e) {
      emit(RideError(message: 'Failed to load rides: ${e.toString()}'));
    }
  }

  Future<void> _onCreateRideOffer(CreateRideOfferEvent event, Emitter<RideState> emit) async {
    emit(RideLoading());
    
    try {
      if (_isar == null) {
        _isar = await IsarDb.instance;
      }
      
      final rideOffer = RideOffer(
        departureLat: event.departureLat,
        departureLng: event.departureLng,
        destinationLat: event.destinationLat,
        destinationLng: event.destinationLng,
        from: event.from,
        to: event.to,
        dateTime: event.dateTime,
        availableSeats: event.availableSeats,
        price: event.price,
        description: event.description,
        driverName: event.driverName,
        driverId: event.driverId,
        vehicleInfo: event.vehicleInfo,
      );

      await _isar!.writeTxn(() async {
        await _isar!.rideOffers.put(rideOffer);
      });

      emit(RideCreated(ride: rideOffer));
      
      // Also emit updated list
      final rides = await _isar!.rideOffers.where().findAll();
      emit(RideLoaded(rides: rides));
    } catch (e) {
      emit(RideError(message: 'Failed to create ride offer: ${e.toString()}'));
    }
  }

  Future<void> _onSearchRides(SearchRidesEvent event, Emitter<RideState> emit) async {
    emit(RideLoading());
    
    try {
      if (_isar == null) {
        _isar = await IsarDb.instance;
      }
      
      // Start with a query builder
      final queryBuilder = _isar!.rideOffers.where();
      
      // Add filters based on search criteria
      if (event.date != null) {
        final startOfDay = DateTime(event.date!.year, event.date!.month, event.date!.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));
        
        queryBuilder.dateTimeBetween(startOfDay, endOfDay);
      }
      
      // Execute the query
      List<RideOffer> rides = await queryBuilder.findAll();
      
      // Apply text-based filters in memory (since Isar doesn't support full-text search directly)
      if (event.from.isNotEmpty) {
        rides = rides.where((ride) => 
          ride.from.toLowerCase().contains(event.from.toLowerCase())
        ).toList();
      }
      
      if (event.to.isNotEmpty) {
        rides = rides.where((ride) => 
          ride.to.toLowerCase().contains(event.to.toLowerCase())
        ).toList();
      }
      
      emit(RideLoaded(rides: rides));
    } catch (e) {
      emit(RideError(message: 'Failed to search rides: ${e.toString()}'));
    }
  }

  Future<void> _onBookRide(BookRideEvent event, Emitter<RideState> emit) async {
    emit(RideLoading());
    
    try {
      if (_isar == null) {
        _isar = await IsarDb.instance;
      }
      
      // Find the ride by ID
      final rideId = int.tryParse(event.rideId);
      if (rideId != null) {
        final ride = await _isar!.rideOffers.get(rideId);
        
        if (ride != null) {
          // Check if enough seats are available
          if (ride.availableSeats >= event.seatsRequested) {
            // Update available seats
            ride.availableSeats -= event.seatsRequested;
            
            // Save the updated ride
            await _isar!.writeTxn(() async {
              await _isar!.rideOffers.put(ride);
            });
            
            emit(RideBooked(message: 'Ride booked successfully!'));
            
            // Reload rides to show updated availability
            final rides = await _isar!.rideOffers.where().findAll();
            emit(RideLoaded(rides: rides));
          } else {
            emit(RideError(message: 'Not enough seats available'));
          }
        } else {
          emit(RideError(message: 'Ride not found'));
        }
      } else {
        emit(RideError(message: 'Invalid ride ID'));
      }
    } catch (e) {
      emit(RideError(message: 'Failed to book ride: ${e.toString()}'));
    }
  }

  Future<void> _onCancelRide(CancelRideEvent event, Emitter<RideState> emit) async {
    emit(RideLoading());
    
    try {
      if (_isar == null) {
        _isar = await IsarDb.instance;
      }
      
      final rideId = int.tryParse(event.rideId);
      if (rideId != null) {
        // Delete the ride
        await _isar!.writeTxn(() async {
          final success = await _isar!.rideOffers.delete(rideId);
          if (!success) {
            emit(RideError(message: 'Ride not found'));
            return;
          }
        });
        
        // Reload rides
        final rides = await _isar!.rideOffers.where().findAll();
        emit(RideLoaded(rides: rides));
      } else {
        emit(RideError(message: 'Invalid ride ID'));
      }
    } catch (e) {
      emit(RideError(message: 'Failed to cancel ride: ${e.toString()}'));
    }
  }
}
