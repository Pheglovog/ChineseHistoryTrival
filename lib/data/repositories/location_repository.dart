import '../local/database/app_database.dart';

class LocationRepository {
  final AppDatabase _db;

  LocationRepository(this._db);

  // Watch all dynasties
  Stream<List<Dynasty>> watchDynasties() => _db.dynastyDao.watchAllDynasties();

  // Watch locations by dynasty
  Stream<List<AncientLocation>> watchLocationsByDynasty(int dynastyId) =>
      _db.ancientLocationDao.watchByDynasty(dynastyId);

  // Watch locations by dynasty and admin level
  Stream<List<AncientLocation>> watchLocationsByDynastyAndLevel(
    int dynastyId,
    String adminLevel,
  ) =>
      _db.ancientLocationDao.watchByDynastyAndLevel(dynastyId, adminLevel);

  // Watch children of a location
  Stream<List<AncientLocation>> watchChildren(int parentLocationId) =>
      _db.ancientLocationDao.watchChildren(parentLocationId);

  // Get location by id
  Future<AncientLocation> getAncientLocation(int id) =>
      _db.ancientLocationDao.getById(id);

  // Get modern location by name
  Future<List<ModernLocation>> searchModernLocations(String name) =>
      _db.modernLocationDao.getByName(name);

  // Get cached match
  Future<LocationMatch?> getCachedMatch(int ancientLocationId) =>
      _db.locationMatchDao.getCachedMatch(ancientLocationId);

  // Watch matches for an ancient location
  Stream<List<LocationMatch>> watchMatches(int ancientLocationId) =>
      _db.locationMatchDao.watchByAncientLocationId(ancientLocationId);
}
