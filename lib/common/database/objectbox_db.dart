import 'package:objectbox/objectbox.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mpitana/screens/offerRide/models/location.dart';
import 'package:mpitana/screens/offerRide/models/ride_offer.dart';
import 'package:mpitana/screens/profile/models/user_profile.dart';
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
  
  // User Profile operations
  static Future<Box<UserProfile>> get userProfileBox async {
    final store = await instance;
    return store.box<UserProfile>();
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
}
