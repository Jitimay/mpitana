import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:mpitana/common/database/isar_db.dart';
import 'package:mpitana/screens/offerRide/models/location.dart';

class LocationService {
  static Future<int> saveLocation(Location location) async {
    try {
      final db = await IsarDb.instance;
      int id = -1;
      
      await db.writeTxn(() async {
        id = await db.locations.put(location);
      });
      
      return id;
    } catch (e) {
      debugPrint('Error saving location: $e');
      return -1;
    }
  }
  
  static Future<List<Location>> getRecentLocations({bool? isDeparture}) async {
    try {
      final db = await IsarDb.instance;
      
      if (isDeparture != null) {
        return await db.locations
            .filter()
            .isDepartureEqualTo(isDeparture)
            .sortByCreatedAtDesc()
            .limit(5)
            .findAll();
      } else {
        return await db.locations
            .where()
            .sortByCreatedAtDesc()
            .limit(10)
            .findAll();
      }
    } catch (e) {
      debugPrint('Error getting recent locations: $e');
      return [];
    }
  }
  
  static Future<void> deleteLocation(int id) async {
    try {
      final db = await IsarDb.instance;
      
      await db.writeTxn(() async {
        await db.locations.delete(id);
      });
    } catch (e) {
      debugPrint('Error deleting location: $e');
    }
  }
  
  static Future<void> clearAllLocations() async {
    try {
      final db = await IsarDb.instance;
      
      await db.writeTxn(() async {
        await db.locations.clear();
      });
    } catch (e) {
      debugPrint('Error clearing locations: $e');
    }
  }
}
