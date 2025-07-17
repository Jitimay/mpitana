import 'package:flutter/foundation.dart';
import 'package:mpitana/screens/offerRide/models/location.dart';
import 'package:mpitana/common/database/objectbox_db.dart';

/// Local storage implementation using ObjectBox
class LocalStorage {
  
  static Future<void> saveLocation(Location location) async {
    try {
      await ObjectBoxDb.saveLocation(location);
    } catch (e) {
      debugPrint('Error saving location: $e');
    }
  }
  
  static Future<List<Location>> getRecentLocations({bool? isDeparture}) async {
    try {
      List<Location> locations;
      
      if (isDeparture != null) {
        locations = await ObjectBoxDb.getLocationsByType(isDeparture);
      } else {
        locations = await ObjectBoxDb.getAllLocations();
      }
      
      // Sort by createdAt (most recent first)
      locations.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      // Limit to 5 or 10 items
      if (locations.length > (isDeparture != null ? 5 : 10)) {
        locations = locations.sublist(0, isDeparture != null ? 5 : 10);
      }
      
      return locations;
    } catch (e) {
      debugPrint('Error getting locations: $e');
      return [];
    }
  }
  
  static Future<bool> deleteLocation(int id) async {
    try {
      return await ObjectBoxDb.deleteLocation(id);
    } catch (e) {
      debugPrint('Error deleting location: $e');
      return false;
    }
  }
  
  static Future<List<Location>> getAllLocations() async {
    try {
      return await ObjectBoxDb.getAllLocations();
    } catch (e) {
      debugPrint('Error getting all locations: $e');
      return [];
    }
  }
}
