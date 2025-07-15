import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mpitana/screens/offerRide/models/location.dart';
import 'package:mpitana/screens/offerRide/models/ride_offer.dart';

class IsarDb {
  static Isar? _isar;
  
  static Future<Isar> get instance async {
    if (_isar != null) return _isar!;
    
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [LocationSchema, RideOfferSchema],
      directory: dir.path,
    );
    
    return _isar!;
  }
  
  static Future<void> close() async {
    await _isar?.close();
    _isar = null;
  }
}
