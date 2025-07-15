import 'package:isar/isar.dart';

part 'location.g.dart';

@collection
class Location {
  Id id = Isar.autoIncrement;
  
  // Coordinates
  late double latitude;
  late double longitude;
  
  // Address information
  late String address;
  String? city;
  String? country;
  
  // Type of location (departure or destination)
  late bool isDeparture;
  
  // Timestamp
  @Index()
  late DateTime createdAt;
  
  // Default constructor
  Location();
  
  // Named constructor for creating instances with parameters
  Location.create({
    required this.latitude,
    required this.longitude,
    required this.address,
    this.city,
    this.country,
    required this.isDeparture,
  }) {
    createdAt = DateTime.now();
  }
}