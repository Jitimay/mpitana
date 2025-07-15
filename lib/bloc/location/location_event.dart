abstract class LocationEvent {}

class RequestLocationPermissionEvent extends LocationEvent {}

class GetCurrentLocationEvent extends LocationEvent {}

class UpdateLocationEvent extends LocationEvent {
  final double latitude;
  final double longitude;
  
  UpdateLocationEvent({required this.latitude, required this.longitude});
}
