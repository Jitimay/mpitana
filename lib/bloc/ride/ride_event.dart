abstract class RideEvent {}

class LoadRidesEvent extends RideEvent {}

class CreateRideOfferEvent extends RideEvent {
  final String from;
  final String to;
  final double departureLat;
  final double departureLng;
  final double destinationLat;
  final double destinationLng;
  final DateTime dateTime;
  final int availableSeats;
  final double price;
  final String description;
  final String? driverName;
  final String? driverId;
  final String? vehicleInfo;
  
  CreateRideOfferEvent({
    required this.from,
    required this.to,
    required this.departureLat,
    required this.departureLng,
    required this.destinationLat,
    required this.destinationLng,
    required this.dateTime,
    required this.availableSeats,
    required this.price,
    required this.description,
    this.driverName,
    this.driverId,
    this.vehicleInfo,
  });
}

class SearchRidesEvent extends RideEvent {
  final String from;
  final String to;
  final DateTime? date;
  
  SearchRidesEvent({
    required this.from,
    required this.to,
    this.date,
  });
}

class BookRideEvent extends RideEvent {
  final String rideId;
  final int seatsRequested;
  
  BookRideEvent({
    required this.rideId,
    required this.seatsRequested,
  });
}

class CancelRideEvent extends RideEvent {
  final String rideId;
  
  CancelRideEvent({required this.rideId});
}
