import 'package:objectbox/objectbox.dart';

@Entity()
class Rating {
  @Id()
  int id = 0;

  // User references
  late String raterId; // User who gives the rating
  late String ratedUserId; // User who receives the rating
  
  // Ride reference
  late int rideBookingId; // Reference to the RideBooking
  late int rideOfferId; // Reference to the RideOffer for easier queries
  
  // Rating details
  late double rating; // 1.0 to 5.0
  
  String? review; // Optional text review
  
  // Rating categories (optional detailed ratings)
  double? punctualityRating; // How on-time was the person
  double? communicationRating; // How well did they communicate
  double? safetyRating; // How safe did they make you feel
  double? cleanlinessRating; // How clean was the vehicle (for driver ratings)
  double? friendlinessRating; // How friendly were they
  
  @Property(type: PropertyType.date)
  late DateTime createdAt;
  
  @Property(type: PropertyType.date)
  DateTime? updatedAt;
  
  // Rating type to distinguish between driver and rider ratings
  @Index()
  late String ratingType; // 'driver_rating' or 'rider_rating'
  
  // Additional context
  String? tags; // Comma-separated tags like "punctual,friendly,safe"
  
  Rating({
    required this.raterId,
    required this.ratedUserId,
    required this.rideBookingId,
    required this.rideOfferId,
    required this.rating,
    required this.ratingType,
    this.review,
    this.punctualityRating,
    this.communicationRating,
    this.safetyRating,
    this.cleanlinessRating,
    this.friendlinessRating,
    this.tags,
    DateTime? createdAt,
    this.updatedAt,
  }) {
    this.createdAt = createdAt ?? DateTime.now();
  }
  
  // Helper methods
  bool get isDriverRating => ratingType == 'driver_rating';
  bool get isRiderRating => ratingType == 'rider_rating';
  
  // Calculate overall rating from category ratings
  double get calculatedOverallRating {
    final ratings = [
      punctualityRating,
      communicationRating,
      safetyRating,
      cleanlinessRating,
      friendlinessRating,
    ].where((r) => r != null).cast<double>();
    
    if (ratings.isEmpty) return rating;
    
    return ratings.reduce((a, b) => a + b) / ratings.length;
  }
  
  // Get tags as a list
  List<String> get tagsList {
    if (tags == null || tags!.isEmpty) return [];
    return tags!.split(',').map((tag) => tag.trim()).toList();
  }
  
  // Set tags from a list
  void setTags(List<String> tagList) {
    tags = tagList.join(',');
  }
  
  // Update the rating
  void updateRating({
    double? newRating,
    String? newReview,
    double? newPunctualityRating,
    double? newCommunicationRating,
    double? newSafetyRating,
    double? newCleanlinessRating,
    double? newFriendlinessRating,
    String? newTags,
  }) {
    if (newRating != null) rating = newRating;
    if (newReview != null) review = newReview;
    if (newPunctualityRating != null) punctualityRating = newPunctualityRating;
    if (newCommunicationRating != null) communicationRating = newCommunicationRating;
    if (newSafetyRating != null) safetyRating = newSafetyRating;
    if (newCleanlinessRating != null) cleanlinessRating = newCleanlinessRating;
    if (newFriendlinessRating != null) friendlinessRating = newFriendlinessRating;
    if (newTags != null) tags = newTags;
    
    updatedAt = DateTime.now();
  }
}
