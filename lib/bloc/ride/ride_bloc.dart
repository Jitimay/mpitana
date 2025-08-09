import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mpitana/objectbox.g.dart';
import 'package:objectbox/objectbox.dart';
import '../../screens/offerRide/models/ride_offer.dart';
import '../../common/database/objectbox_db.dart';
import 'ride_event.dart';
import 'ride_state.dart';

class RideBloc extends Bloc<RideEvent, RideState> {
  Store? _store;
  Box<RideOffer>? _rideOfferBox;

  RideBloc() : super(RideInitial()) {
    _initializeObjectBox();
    on<LoadRidesEvent>(_onLoadRides);
    on<LoadAvailableRides>(_onLoadAvailableRides);
    on<CreateRideOfferEvent>(_onCreateRideOffer);
    on<SearchRidesEvent>(_onSearchRides);
    on<BookRideEvent>(_onBookRide);
    on<CancelRideEvent>(_onCancelRide);
  }

  Future<void> _initializeObjectBox() async {
    _store = await ObjectBoxDb.instance;
    _rideOfferBox = _store!.box<RideOffer>();
  }

  Future<void> _onLoadRides(LoadRidesEvent event, Emitter<RideState> emit) async {
    emit(RideLoading());
    
    try {
      if (_rideOfferBox == null) {
        _store = await ObjectBoxDb.instance;
        _rideOfferBox = _store!.box<RideOffer>();
      }
      
      final rides = _rideOfferBox!.getAll();
      emit(RideLoaded(rides: rides));
    } catch (e) {
      emit(RideError(message: 'Failed to load rides: ${e.toString()}'));
    }
  }

  Future<void> _onLoadAvailableRides(LoadAvailableRides event, Emitter<RideState> emit) async {
    emit(RideLoading());
    
    try {
      if (_rideOfferBox == null) {
        _store = await ObjectBoxDb.instance;
        _rideOfferBox = _store!.box<RideOffer>();
      }
      
      // Get all rides and filter for active ones with available seats
      final allRides = _rideOfferBox!.getAll();
      final availableRides = allRides.where((ride) => 
        ride.isActive && 
        ride.availableSeats > 0 && 
        ride.dateTime.isAfter(DateTime.now())
      ).toList();
      
      // Sort by date/time
      availableRides.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      
      emit(RideLoaded(rides: availableRides));
    } catch (e) {
      emit(RideError(message: 'Failed to load available rides: ${e.toString()}'));
    }
  }

  Future<void> _onCreateRideOffer(CreateRideOfferEvent event, Emitter<RideState> emit) async {
    emit(RideLoading());
    
    try {
      if (_rideOfferBox == null) {
        _store = await ObjectBoxDb.instance;
        _rideOfferBox = _store!.box<RideOffer>();
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

      final id = _rideOfferBox!.put(rideOffer);
      rideOffer.id = id;

      emit(RideCreated(ride: rideOffer));
      
      // Emit updated available rides list (filtered)
      final allRides = _rideOfferBox!.getAll();
      final availableRides = allRides.where((ride) => 
        ride.isActive && 
        ride.availableSeats > 0 && 
        ride.dateTime.isAfter(DateTime.now())
      ).toList();
      
      // Sort by date/time
      availableRides.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      
      emit(RideLoaded(rides: availableRides));
    } catch (e) {
      emit(RideError(message: 'Failed to create ride offer: ${e.toString()}'));
    }
  }

  Future<void> _onSearchRides(SearchRidesEvent event, Emitter<RideState> emit) async {
    emit(RideLoading());
    
    try {
      if (_rideOfferBox == null) {
        _store = await ObjectBoxDb.instance;
        _rideOfferBox = _store!.box<RideOffer>();
      }
      
      List<RideOffer> rides = [];
      
      // Filter by date if provided
      if (event.date != null) {
        final startOfDay = DateTime(event.date!.year, event.date!.month, event.date!.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));
        
        final query = _rideOfferBox!.query(
          RideOffer_.dateTime.between(
            startOfDay.millisecondsSinceEpoch, 
            endOfDay.millisecondsSinceEpoch
          )
        ).build();
        
        rides = query.find();
        query.close();
      } else {
        rides = _rideOfferBox!.getAll();
      }
      
      // Apply text-based filters in memory
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
      if (_rideOfferBox == null) {
        _store = await ObjectBoxDb.instance;
        _rideOfferBox = _store!.box<RideOffer>();
      }
      
      // Find the ride by ID
      final rideId = int.tryParse(event.rideId);
      if (rideId != null) {
        final ride = _rideOfferBox!.get(rideId);
        
        if (ride != null) {
          // Check if enough seats are available
          if (ride.availableSeats >= event.seatsRequested) {
            // Update available seats
            ride.availableSeats -= event.seatsRequested;
            
            // Save the updated ride
            _rideOfferBox!.put(ride);
            
            emit(RideBooked(message: 'Ride booked successfully!'));
            
            // Reload rides to show updated availability
            final rides = _rideOfferBox!.getAll();
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
      if (_rideOfferBox == null) {
        _store = await ObjectBoxDb.instance;
        _rideOfferBox = _store!.box<RideOffer>();
      }
      
      final rideId = int.tryParse(event.rideId);
      if (rideId != null) {
        // Delete the ride
        final success = _rideOfferBox!.remove(rideId);
        if (!success) {
          emit(RideError(message: 'Ride not found'));
          return;
        }
        
        // Reload rides
        final rides = _rideOfferBox!.getAll();
        emit(RideLoaded(rides: rides));
      } else {
        emit(RideError(message: 'Invalid ride ID'));
      }
    } catch (e) {
      emit(RideError(message: 'Failed to cancel ride: ${e.toString()}'));
    }
  }
}
