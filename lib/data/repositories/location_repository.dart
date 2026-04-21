import '../../domain/entities/ancient_location.dart';
import '../../domain/entities/dynasty.dart';
import '../../domain/entities/location_match.dart';
import '../../domain/entities/modern_location.dart';
import '../local/database/app_database.dart';

class LocationRepository {
  final AppDatabase _appDb;

  LocationRepository(this._appDb);

  Stream<List<Dynasty>> watchDynasties() async* {
    final dao = await _appDb.dynastyDao;
    yield* dao.watchAllDynasties();
  }

  Stream<List<AncientLocation>> watchLocationsByDynasty(int dynastyId) async* {
    final dao = await _appDb.ancientLocationDao;
    yield* dao.watchByDynasty(dynastyId);
  }

  Stream<List<AncientLocation>> watchLocationsByDynastyAndLevel(
    int dynastyId,
    String adminLevel,
  ) async* {
    final dao = await _appDb.ancientLocationDao;
    yield* dao.watchByDynastyAndLevel(dynastyId, adminLevel);
  }

  Stream<List<AncientLocation>> watchChildren(int parentLocationId) async* {
    final dao = await _appDb.ancientLocationDao;
    yield* dao.watchChildren(parentLocationId);
  }

  Future<AncientLocation> getAncientLocation(int id) async {
    final dao = await _appDb.ancientLocationDao;
    return dao.getById(id);
  }

  Future<List<ModernLocation>> searchModernLocations(String name) async {
    final dao = await _appDb.modernLocationDao;
    return dao.getByName(name);
  }

  Future<LocationMatch?> getCachedMatch(int ancientLocationId) async {
    final dao = await _appDb.locationMatchDao;
    return dao.getCachedMatch(ancientLocationId);
  }

  Stream<List<LocationMatch>> watchMatches(int ancientLocationId) async* {
    final dao = await _appDb.locationMatchDao;
    yield* dao.watchByAncientLocationId(ancientLocationId);
  }
}
