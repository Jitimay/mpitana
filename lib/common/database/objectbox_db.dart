import 'package:objectbox/objectbox.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mpitana/screens/offerRide/models/location.dart';
import 'package:mpitana/screens/offerRide/models/ride_offer.dart';
import 'package:mpitana/screens/offerRide/models/ride_booking.dart';
import 'package:mpitana/screens/offerRide/models/rating.dart';
import 'package:mpitana/screens/profile/models/user_profile.dart';
import 'package:mpitana/screens/wallet/models/wallet.dart';
import 'package:mpitana/screens/wallet/models/transaction.dart';
import 'package:mpitana/screens/wallet/models/payment_method.dart';
import 'package:mpitana/objectbox.g.dart';

class ObjectBoxDb {
  static Store? _store;
  
  static Future<Store> get instance async {
    if (_store != null) return _store!;
    
    final dir = await getApplicationDocumentsDirectory();
    _store = await openStore(directory: '${dir.path}/objectbox');
    
    return _store!;
  }
  
  static Future<void> close() async {
    _store?.close();
    _store = null;
  }
  
  // Location operations
  static Future<Box<Location>> get locationBox async {
    final store = await instance;
    return store.box<Location>();
  }
  
  static Future<Box<RideOffer>> get rideOfferBox async {
    final store = await instance;
    return store.box<RideOffer>();
  }
  
  static Future<Box<RideBooking>> get rideBookingBox async {
    final store = await instance;
    return store.box<RideBooking>();
  }
  
  static Future<Box<Rating>> get ratingBox async {
    final store = await instance;
    return store.box<Rating>();
  }
  
  // Helper methods for Location
  static Future<int> saveLocation(Location location) async {
    final box = await locationBox;
    return box.put(location);
  }
  
  static Future<List<Location>> getAllLocations() async {
    final box = await locationBox;
    return box.getAll();
  }
  
  static Future<Location?> getLocation(int id) async {
    final box = await locationBox;
    return box.get(id);
  }
  
  static Future<bool> deleteLocation(int id) async {
    final box = await locationBox;
    return box.remove(id);
  }
  
  static Future<List<Location>> getLocationsByType(bool isDeparture) async {
    final box = await locationBox;
    final query = box.query(Location_.isDeparture.equals(isDeparture)).build();
    final results = query.find();
    query.close();
    return results;
  }
  
  // Helper methods for RideOffer
  static Future<int> saveRideOffer(RideOffer rideOffer) async {
    final box = await rideOfferBox;
    return box.put(rideOffer);
  }
  
  static Future<List<RideOffer>> getAllRideOffers() async {
    final box = await rideOfferBox;
    return box.getAll();
  }
  
  static Future<RideOffer?> getRideOffer(int id) async {
    final box = await rideOfferBox;
    return box.get(id);
  }
  
  static Future<bool> deleteRideOffer(int id) async {
    final box = await rideOfferBox;
    return box.remove(id);
  }
  
  static Future<List<RideOffer>> getActiveRideOffers() async {
    final box = await rideOfferBox;
    final query = box.query(RideOffer_.isActive.equals(true)).build();
    final results = query.find();
    query.close();
    return results;
  }
  
  static Future<List<RideOffer>> getRideOffersByDateRange(DateTime start, DateTime end) async {
    final box = await rideOfferBox;
    final query = box.query(
      RideOffer_.dateTime.between(start.millisecondsSinceEpoch, end.millisecondsSinceEpoch)
    ).build();
    final results = query.find();
    query.close();
    return results;
  }
  
  static Future<List<RideOffer>> getRideOffersByDriver(String driverId) async {
    final box = await rideOfferBox;
    final query = box.query(RideOffer_.driverId.equals(driverId)).build();
    final results = query.find();
    query.close();
    return results;
  }
  
  // Helper methods for RideBooking
  static Future<int> saveRideBooking(RideBooking booking) async {
    final box = await rideBookingBox;
    return box.put(booking);
  }
  
  static Future<List<RideBooking>> getAllRideBookings() async {
    final box = await rideBookingBox;
    return box.getAll();
  }
  
  static Future<RideBooking?> getRideBooking(int id) async {
    final box = await rideBookingBox;
    return box.get(id);
  }
  
  static Future<bool> deleteRideBooking(int id) async {
    final box = await rideBookingBox;
    return box.remove(id);
  }
  
  static Future<List<RideBooking>> getRideBookingsByRider(String riderId) async {
    final box = await rideBookingBox;
    final query = box.query(RideBooking_.riderId.equals(riderId)).build();
    final results = query.find();
    query.close();
    return results;
  }
  
  static Future<List<RideBooking>> getRideBookingsByDriver(String driverId) async {
    final box = await rideBookingBox;
    final query = box.query(RideBooking_.driverId.equals(driverId)).build();
    final results = query.find();
    query.close();
    return results;
  }
  
  static Future<List<RideBooking>> getRideBookingsByRideOffer(int rideOfferId) async {
    final box = await rideBookingBox;
    final query = box.query(RideBooking_.rideOfferId.equals(rideOfferId)).build();
    final results = query.find();
    query.close();
    return results;
  }
  
  static Future<List<RideBooking>> getCompletedRideBookings() async {
    final box = await rideBookingBox;
    final query = box.query(RideBooking_.status.equals('completed')).build();
    final results = query.find();
    query.close();
    return results;
  }
  
  static Future<List<RideBooking>> getRideBookingsForRating(String userId) async {
    final box = await rideBookingBox;
    final query = box.query(
      RideBooking_.status.equals('completed')
        .and(RideBooking_.riderId.equals(userId).or(RideBooking_.driverId.equals(userId)))
    ).build();
    final results = query.find();
    query.close();
    
    // Filter bookings that can be rated and haven't been rated yet
    final ratingsBox = await ratingBox;
    final filteredResults = <RideBooking>[];
    
    for (final booking in results) {
      if (booking.canBeRated) {
        // Check if this booking has already been rated by this user
        final existingRatingQuery = ratingsBox.query(
          Rating_.rideBookingId.equals(booking.id)
            .and(Rating_.raterId.equals(userId))
        ).build();
        final existingRatings = existingRatingQuery.find();
        existingRatingQuery.close();
        
        if (existingRatings.isEmpty) {
          filteredResults.add(booking);
        }
      }
    }
    
    return filteredResults;
  }
  
  // Helper methods for Rating
  static Future<int> saveRating(Rating rating) async {
    final box = await ratingBox;
    return box.put(rating);
  }
  
  static Future<List<Rating>> getAllRatings() async {
    final box = await ratingBox;
    return box.getAll();
  }
  
  static Future<Rating?> getRating(int id) async {
    final box = await ratingBox;
    return box.get(id);
  }
  
  static Future<bool> deleteRating(int id) async {
    final box = await ratingBox;
    return box.remove(id);
  }
  
  static Future<List<Rating>> getRatingsForUser(String userId) async {
    final box = await ratingBox;
    final query = box.query(Rating_.ratedUserId.equals(userId)).build();
    final results = query.find();
    query.close();
    return results;
  }
  
  static Future<List<Rating>> getRatingsByUser(String userId) async {
    final box = await ratingBox;
    final query = box.query(Rating_.raterId.equals(userId)).build();
    final results = query.find();
    query.close();
    return results;
  }
  
  static Future<Rating?> getRatingForBooking(int bookingId, String raterId) async {
    final box = await ratingBox;
    final query = box.query(
      Rating_.rideBookingId.equals(bookingId)
        .and(Rating_.raterId.equals(raterId))
    ).build();
    final results = query.find();
    query.close();
    
    return results.isNotEmpty ? results.first : null;
  }
  
  static Future<double> calculateUserAverageRating(String userId) async {
    final ratings = await getRatingsForUser(userId);
    if (ratings.isEmpty) return 0.0;
    
    final totalRating = ratings.fold<double>(0.0, (sum, rating) => sum + rating.rating);
    return totalRating / ratings.length;
  }
  
  static Future<Map<String, dynamic>> getUserRatingStats(String userId) async {
    final ratings = await getRatingsForUser(userId);
    
    if (ratings.isEmpty) {
      return {
        'averageRating': 0.0,
        'totalRatings': 0,
        'ratingDistribution': <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
        'driverRatings': 0,
        'riderRatings': 0,
      };
    }
    
    final totalRating = ratings.fold<double>(0.0, (sum, rating) => sum + rating.rating);
    final averageRating = totalRating / ratings.length;
    
    final ratingDistribution = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    int driverRatings = 0;
    int riderRatings = 0;
    
    for (final rating in ratings) {
      final roundedRating = rating.rating.round();
      ratingDistribution[roundedRating] = (ratingDistribution[roundedRating] ?? 0) + 1;
      
      if (rating.isDriverRating) {
        driverRatings++;
      } else {
        riderRatings++;
      }
    }
    
    return {
      'averageRating': averageRating,
      'totalRatings': ratings.length,
      'ratingDistribution': ratingDistribution,
      'driverRatings': driverRatings,
      'riderRatings': riderRatings,
    };
  }
  
  // User Profile operations
  static Future<Box<UserProfile>> get userProfileBox async {
    final store = await instance;
    return store.box<UserProfile>();
  }
  
  static Future<Box<Wallet>> get walletBox async {
    final store = await instance;
    return store.box<Wallet>();
  }
  
  static Future<Box<WalletTransaction>> get transactionBox async {
    final store = await instance;
    return store.box<WalletTransaction>();
  }
  
  static Future<Box<PaymentMethod>> get paymentMethodBox async {
    final store = await instance;
    return store.box<PaymentMethod>();
  }
  
  static Future<int> saveUserProfile(UserProfile profile) async {
    final box = await userProfileBox;
    return box.put(profile);
  }
  
  static Future<UserProfile?> getUserProfileById(int id) async {
    final box = await userProfileBox;
    return box.get(id);
  }
  
  static Future<UserProfile?> getUserProfileByUserId(String userId) async {
    final box = await userProfileBox;
    final query = box.query(UserProfile_.userId.equals(userId)).build();
    final results = query.find();
    query.close();
    
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }
  
  static Future<List<UserProfile>> getAllUserProfiles() async {
    final box = await userProfileBox;
    return box.getAll();
  }
  
  static Future<bool> deleteUserProfile(int id) async {
    final box = await userProfileBox;
    return box.remove(id);
  }
  
  static Future<bool> deleteUserProfileByUserId(String userId) async {
    final box = await userProfileBox;
    final query = box.query(UserProfile_.userId.equals(userId)).build();
    final results = query.find();
    query.close();
    
    if (results.isNotEmpty) {
      return box.remove(results.first.id);
    }
    return false;
  }
  
  // Update user profile rating after new rating is added
  static Future<void> updateUserProfileRating(String userId) async {
    final profile = await getUserProfileByUserId(userId);
    if (profile != null) {
      final averageRating = await calculateUserAverageRating(userId);
      final updatedProfile = profile.copyWith(rating: averageRating);
      await saveUserProfile(updatedProfile);
    }
  }
}
