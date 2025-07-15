import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'location_event.dart';
import 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  LocationBloc() : super(LocationInitial()) {
    on<RequestLocationPermissionEvent>(_onRequestLocationPermission);
    on<GetCurrentLocationEvent>(_onGetCurrentLocation);
    on<UpdateLocationEvent>(_onUpdateLocation);
  }

  Future<void> _onRequestLocationPermission(
    RequestLocationPermissionEvent event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading());

    try {
      // Check if location services are enabled
      final serviceStatus = await Permission.location.serviceStatus;
      if (!serviceStatus.isEnabled) {
        emit(LocationPermissionDenied(
          message: 'Location services are disabled. Please enable them in device settings.',
        ));
        return;
      }

      // Check current permission status
      final status = await Permission.location.status;
      
      if (status.isGranted) {
        emit(LocationPermissionGranted());
      } else {
        // Request permission
        final newStatus = await Permission.location.request();
        
        if (newStatus.isGranted) {
          emit(LocationPermissionGranted());
        } else if (newStatus.isPermanentlyDenied) {
          emit(LocationPermissionDenied(
            message: 'Location permission permanently denied. Please enable it in app settings.',
          ));
        } else {
          emit(LocationPermissionDenied(
            message: 'Location permission denied.',
          ));
        }
      }
    } catch (e) {
      emit(LocationError(message: 'Failed to request location permission: ${e.toString()}'));
    }
  }

  Future<void> _onGetCurrentLocation(
    GetCurrentLocationEvent event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading());

    try {
      // Check if location permission is granted
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || 
          permission == LocationPermission.deniedForever) {
        emit(LocationPermissionDenied(
          message: 'Location permission is required to get current location.',
        ));
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get address from coordinates
      String? address;
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          address = '${placemark.street}, ${placemark.locality}, ${placemark.country}';
        }
      } catch (e) {
        // Address lookup failed, but we still have coordinates
        print('Failed to get address: $e');
      }

      emit(LocationLoaded(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
      ));
    } catch (e) {
      emit(LocationError(message: 'Failed to get current location: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateLocation(
    UpdateLocationEvent event,
    Emitter<LocationState> emit,
  ) async {
    try {
      // Get address from coordinates
      String? address;
      try {
        final placemarks = await placemarkFromCoordinates(
          event.latitude,
          event.longitude,
        );
        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          address = '${placemark.street}, ${placemark.locality}, ${placemark.country}';
        }
      } catch (e) {
        print('Failed to get address: $e');
      }

      emit(LocationLoaded(
        latitude: event.latitude,
        longitude: event.longitude,
        address: address,
      ));
    } catch (e) {
      emit(LocationError(message: 'Failed to update location: ${e.toString()}'));
    }
  }
}
