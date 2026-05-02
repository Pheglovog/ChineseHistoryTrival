import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/travel_route.dart';
import '../../domain/entities/route_stop.dart';
import '../../domain/entities/ancient_location.dart';
import '../../domain/entities/modern_location.dart';
import '../../data/local/database/app_database.dart';
import 'database_provider.dart';
import 'current_dynasty_provider.dart';

class RouteWithStops {
  final TravelRoute route;
  final List<RouteStopWithDetails> stops;

  RouteWithStops({required this.route, required this.stops});
}

class RouteStopWithDetails {
  final RouteStop stop;
  final AncientLocation? location;
  final ModernLocation? modernLocation;

  RouteStopWithDetails({required this.stop, this.location, this.modernLocation});
}

final routesByDynastyProvider =
    FutureProvider<List<TravelRoute>>((ref) async {
  final db = ref.watch(databaseProvider);
  final dynastyId = ref.watch(currentDynastyIdProvider);
  final dao = await db.travelRouteDao;
  return dao.getByDynasty(dynastyId);
});

final routeDetailProvider =
    FutureProvider.family<TravelRoute, int>((ref, routeId) async {
  final db = ref.watch(databaseProvider);
  final dao = await db.travelRouteDao;
  return dao.getById(routeId);
});

final routeStopsProvider =
    FutureProvider.family<RouteWithStops, int>((ref, routeId) async {
  final db = ref.watch(databaseProvider);
  final routeDao = await db.travelRouteDao;
  final ancientDao = await db.ancientLocationDao;
  final database = await AppDatabase.database;

  final route = await routeDao.getById(routeId);
  final stops = await routeDao.getStops(routeId);

  final stopDetails = <RouteStopWithDetails>[];
  for (final stop in stops) {
    AncientLocation? location;
    ModernLocation? modernLocation;

    try {
      location = await ancientDao.getById(stop.locationId);
    } catch (_) {}

    if (stop.modernLocationId != null) {
      try {
        final modernRows = await database.query(
          'modern_locations',
          where: 'id = ?',
          whereArgs: [stop.modernLocationId],
        );
        if (modernRows.isNotEmpty) {
          modernLocation = ModernLocation.fromRow(modernRows.first);
        }
      } catch (_) {}
    }

    stopDetails.add(RouteStopWithDetails(
      stop: stop,
      location: location,
      modernLocation: modernLocation,
    ));
  }

  return RouteWithStops(route: route, stops: stopDetails);
});
