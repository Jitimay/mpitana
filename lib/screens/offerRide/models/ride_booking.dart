import 'package:objectbox/objectbox.dart';

@Entity()
class RideBooking {
  @Id()
  int id = 0;

  // Foreign keys
  late String riderId; // User who booked the ride
  late String driverId; // User who offered the ride
  late int rideOfferId; // Reference to the RideOffer
  
  // Booking details
  late int seatsBooked;
  late double totalPrice;
  
  @Property(type: PropertyType.date)
  late DateTime bookedAt;
  
  @Property(type: PropertyType.date)
  DateTime? rideCompletedAt;
  
  // Booking status
  @Index()
  late String status; // 'pending', 'confirmed', 'completed', 'cancelled'
  
  // Contact information
  String? riderName;
  String? riderPhone;
  String? driverName;
  String? driverPhone;
  
  // Payment information
  String? paymentMethod;
  String? paymentStatus; // 'pending', 'paid', 'refunded'
  
  // Additional notes
  String? notes;
  
  RideBooking({
    required this.riderId,
    required this.driverId,
    required this.rideOfferId,
    required this.seatsBooked,
    required this.totalPrice,
    this.status = 'pending',
    this.riderName,
    this.riderPhone,
    this.driverName,
    this.driverPhone,
    this.paymentMethod,
    this.paymentStatus = 'pending',
    this.notes,
    DateTime? bookedAt,
    this.rideCompletedAt,
  }) {
    this.bookedAt = bookedAt ?? DateTime.now();
  }
  
  // Helper methods
  bool get isCompleted => status == 'completed';
  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isCancelled => status == 'cancelled';
  
  // Check if ride can be rated (completed and not too old)
  bool get canBeRated {
    if (!isCompleted || rideCompletedAt == null) return false;
    
    // Allow rating within 30 days of completion
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return rideCompletedAt!.isAfter(thirtyDaysAgo);
  }
}
