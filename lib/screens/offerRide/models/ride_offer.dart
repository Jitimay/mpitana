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
  late int bookedSeats; // Track how many seats are booked
  late double price;
  late String description;
  
  @Index()
  @Property(type: PropertyType.date)
  late DateTime createdAt;
  
  // Driver properties
  String? driverName;
  String? driverId;
  String? vehicleInfo;
  String? driverPhone;
  
  @Index()
  late bool isActive;
  
  // Ride status tracking
  @Index()
  late String status; // 'active', 'full', 'completed', 'cancelled'
  
  @Property(type: PropertyType.date)
  DateTime? completedAt;
  
  // Rating summary (calculated from individual ratings)
  double? averageRating;
  int? totalRatings;
  
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
    this.driverPhone,
    this.isActive = true,
    this.bookedSeats = 0,
    this.status = 'active',
    this.completedAt,
    this.averageRating,
    this.totalRatings,
  }) {
    createdAt = DateTime.now();
  }
  
  // Helper methods
  int get remainingSeats => availableSeats - bookedSeats;
  bool get isFull => bookedSeats >= availableSeats;
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  
  // Update booking status
  void updateBookedSeats(int newBookedSeats) {
    bookedSeats = newBookedSeats;
    if (bookedSeats >= availableSeats) {
      status = 'full';
    } else if (status == 'full' && bookedSeats < availableSeats) {
      status = 'active';
    }
  }
  
  // Mark ride as completed
  void markAsCompleted() {
    status = 'completed';
    isActive = false;
    completedAt = DateTime.now();
  }
  
  // Update rating summary
  void updateRatingSummary(double newAverageRating, int newTotalRatings) {
    averageRating = newAverageRating;
    totalRatings = newTotalRatings;
  }
}
