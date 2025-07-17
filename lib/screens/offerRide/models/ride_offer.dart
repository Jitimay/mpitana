import 'package:objectbox/objectbox.dart';

@Entity()
class RideOffer {
  @Id()
  int id = 0;

  // Location properties
  late double departureLat;
  late double departureLng;
  late double destinationLat;
  late double destinationLng;
  
  // Ride details
  late String from;
  late String to;
  
  @Index()
  @Property(type: PropertyType.date)
  late DateTime dateTime;
  
  late int availableSeats;
  late double price;
  late String description;
  
  @Index()
  @Property(type: PropertyType.date)
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
