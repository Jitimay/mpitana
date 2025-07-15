abstract class LocationState {}

class LocationInitial extends LocationState {}

class LocationLoading extends LocationState {}

class LocationPermissionDenied extends LocationState {
  final String message;
  
  LocationPermissionDenied({required this.message});
}

class LocationPermissionGranted extends LocationState {}

class LocationLoaded extends LocationState {
  final double latitude;
  final double longitude;
  final String? address;
  
  LocationLoaded({
    required this.latitude,
    required this.longitude,
    this.address,
  });
}

class LocationError extends LocationState {
  final String message;
  
  LocationError({required this.message});
}
