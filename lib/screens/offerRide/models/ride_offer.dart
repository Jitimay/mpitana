import 'package:isar/isar.dart';

part 'ride_offer.g.dart';

@collection
class RideOffer {
  Id id = Isar.autoIncrement;

  // Location properties
  late double departureLat;
  late double departureLng;
  late double destinationLat;
  late double destinationLng;
  
  // Ride details
  late String from;
  late String to;
  
  @Index()
  late DateTime dateTime;
  
  late int availableSeats;
  late double price;
  late String description;
  
  @Index()
  late DateTime createdAt;
  
  // Optional properties
  String? driverName;
  String? driverId;
  String? vehicleInfo;
  
  @Index()
  late bool isActive;
  
  RideOffer({
    required this.departureLat,
    required this.departureLng,
    required this.destinationLat,
    required this.destinationLng,
    required this.from,
    required this.to,
    required this.dateTime,
    required this.availableSeats,
    required this.price,
    required this.description,
    this.driverName,
    this.driverId,
    this.vehicleInfo,
    this.isActive = true,
  }) {
    createdAt = DateTime.now();
  }
}
