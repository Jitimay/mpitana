import 'package:mpitana/objectbox.g.dart';
import 'package:mpitana/screens/offerRide/models/rating.dart';
import 'package:mpitana/screens/offerRide/models/ride_booking.dart';
import 'package:mpitana/common/database/objectbox_db.dart';
import 'package:mpitana/objectbox.g.dart';

class RatingService {
  // Submit a rating for a completed ride
  static Future<bool> submitRating({
    required String raterId,
    required String ratedUserId,
    required int rideBookingId,
    required int rideOfferId,
    required double rating,
    required String ratingType, // 'driver_rating' or 'rider_rating'
    String? review,
    double? punctualityRating,
    double? communicationRating,
    double? safetyRating,
    double? cleanlinessRating,
    double? friendlinessRating,
    List<String>? tags,
  }) async {
    try {
      // Validate rating range
      if (rating < 1.0 || rating > 5.0) {
        throw ArgumentError('Rating must be between 1.0 and 5.0');
      }
      
      // Check if booking exists and is completed
      final booking = await ObjectBoxDb.getRideBooking(rideBookingId);
      if (booking == null || !booking.isCompleted) {
        throw StateError('Booking not found or not completed');
      }
      
      // Check if user is part of this booking
      if (booking.riderId != raterId && booking.driverId != raterId) {
        throw StateError('User not authorized to rate this booking');
      }
      
      // Check if rating already exists
      final existingRating = await ObjectBoxDb.getRatingForBooking(rideBookingId, raterId);
      if (existingRating != null) {
        throw StateError('Rating already exists for this booking');
      }
      
      // Create new rating
      final newRating = Rating(
        raterId: raterId,
        ratedUserId: ratedUserId,
        rideBookingId: rideBookingId,
        rideOfferId: rideOfferId,
        rating: rating,
        ratingType: ratingType,
        review: review,
        punctualityRating: punctualityRating,
        communicationRating: communicationRating,
        safetyRating: safetyRating,
        cleanlinessRating: cleanlinessRating,
        friendlinessRating: friendlinessRating,
      );
      
      if (tags != null) {
        newRating.setTags(tags);
      }
      
      // Save rating
      await ObjectBoxDb.saveRating(newRating);
      
      // Update user profile rating
      await ObjectBoxDb.updateUserProfileRating(ratedUserId);
      
      // Update ride offer rating summary
      await _updateRideOfferRating(rideOfferId);
      
      return true;
    } catch (e) {
      print('Error submitting rating: $e');
      return false;
    }
  }
  
  // Update an existing rating
  static Future<bool> updateRating({
    required int ratingId,
    required String raterId,
    double? rating,
    String? review,
    double? punctualityRating,
    double? communicationRating,
    double? safetyRating,
    double? cleanlinessRating,
    double? friendlinessRating,
    List<String>? tags,
  }) async {
    try {
      final existingRating = await ObjectBoxDb.getRating(ratingId);
      if (existingRating == null) {
        throw StateError('Rating not found');
      }
      
      // Check if user owns this rating
      if (existingRating.raterId != raterId) {
        throw StateError('User not authorized to update this rating');
      }
      
      // Validate rating range if provided
      if (rating != null && (rating < 1.0 || rating > 5.0)) {
        throw ArgumentError('Rating must be between 1.0 and 5.0');
      }
      
      // Update rating
      existingRating.updateRating(
        newRating: rating,
        newReview: review,
        newPunctualityRating: punctualityRating,
        newCommunicationRating: communicationRating,
        newSafetyRating: safetyRating,
        newCleanlinessRating: cleanlinessRating,
        newFriendlinessRating: friendlinessRating,
        newTags: tags?.join(','),
      );
      
      // Save updated rating
      await ObjectBoxDb.saveRating(existingRating);
      
      // Update user profile rating
      await ObjectBoxDb.updateUserProfileRating(existingRating.ratedUserId);
      
      // Update ride offer rating summary
      await _updateRideOfferRating(existingRating.rideOfferId);
      
      return true;
    } catch (e) {
      print('Error updating rating: $e');
      return false;
    }
  }
  
  // Get ratings for a specific user
  static Future<List<Rating>> getUserRatings(String userId) async {
    return await ObjectBoxDb.getRatingsForUser(userId);
  }
  
  // Get ratings given by a specific user
  static Future<List<Rating>> getRatingsByUser(String userId) async {
    return await ObjectBoxDb.getRatingsByUser(userId);
  }
  
  // Get user rating statistics
  static Future<Map<String, dynamic>> getUserRatingStats(String userId) async {
    return await ObjectBoxDb.getUserRatingStats(userId);
  }
  
  // Get bookings that can be rated by a user
  static Future<List<RideBooking>> getRideBookingsForRating(String userId) async {
    return await ObjectBoxDb.getRideBookingsForRating(userId);
  }
  
  // Check if a booking can be rated by a user
  static Future<bool> canRateBooking(int bookingId, String userId) async {
    final booking = await ObjectBoxDb.getRideBooking(bookingId);
    if (booking == null || !booking.canBeRated) return false;
    
    // Check if user is part of this booking
    if (booking.riderId != userId && booking.driverId != userId) return false;
    
    // Check if rating already exists
    final existingRating = await ObjectBoxDb.getRatingForBooking(bookingId, userId);
    return existingRating == null;
  }
  
  // Get the other user in a booking (for rating purposes)
  static String? getOtherUserInBooking(RideBooking booking, String currentUserId) {
    if (booking.riderId == currentUserId) {
      return booking.driverId;
    } else if (booking.driverId == currentUserId) {
      return booking.riderId;
    }
    return null;
  }
  
  // Determine rating type based on user role in booking
  static String getRatingType(RideBooking booking, String raterId) {
    if (booking.riderId == raterId) {
      return 'driver_rating'; // Rider rating the driver
    } else {
      return 'rider_rating'; // Driver rating the rider
    }
  }
  
  // Get rating summary for a ride offer
  static Future<Map<String, dynamic>> getRideOfferRatingSummary(int rideOfferId) async {
    final ratingBox = await ObjectBoxDb.ratingBox;
    final query = ratingBox.query(Rating_.rideOfferId.equals(rideOfferId)).build();
    final ratings = query.find();
    query.close();
    
    if (ratings.isEmpty) {
      return {
        'averageRating': 0.0,
        'totalRatings': 0,
        'driverRatings': <Rating>[],
        'riderRatings': <Rating>[],
      };
    }
    
    final driverRatings = ratings.where((r) => r.isDriverRating).toList();
    final riderRatings = ratings.where((r) => r.isRiderRating).toList();
    
    final totalRating = ratings.fold<double>(0.0, (sum, rating) => sum + rating.rating);
    final averageRating = totalRating / ratings.length;
    
    return {
      'averageRating': averageRating,
      'totalRatings': ratings.length,
      'driverRatings': driverRatings,
      'riderRatings': riderRatings,
    };
  }
  
  // Private method to update ride offer rating summary
  static Future<void> _updateRideOfferRating(int rideOfferId) async {
    final summary = await getRideOfferRatingSummary(rideOfferId);
    final rideOffer = await ObjectBoxDb.getRideOffer(rideOfferId);
    
    if (rideOffer != null) {
      rideOffer.updateRatingSummary(
        summary['averageRating'],
        summary['totalRatings'],
      );
      await ObjectBoxDb.saveRideOffer(rideOffer);
    }
  }
  
  // Get popular rating tags
  static Future<Map<String, int>> getPopularRatingTags({String? userId, String? ratingType}) async {
    final ratings = userId != null 
        ? await ObjectBoxDb.getRatingsForUser(userId)
        : await ObjectBoxDb.getAllRatings();
    
    final tagCounts = <String, int>{};
    
    for (final rating in ratings) {
      if (ratingType != null && rating.ratingType != ratingType) continue;
      
      for (final tag in rating.tagsList) {
        tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
      }
    }
    
    // Sort by count and return top tags
    final sortedEntries = tagCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return Map.fromEntries(sortedEntries.take(10));
  }
}
