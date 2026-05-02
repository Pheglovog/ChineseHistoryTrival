import 'package:sqflite/sqflite.dart';

import '../../../domain/entities/travel_route.dart';
import '../../../domain/entities/route_stop.dart';
import '../database/schema.dart';

class TravelRouteDao {
  final Database _db;

  TravelRouteDao(this._db);

  Future<List<TravelRoute>> getByDynasty(int dynastyId) async {
    final rows = await _db.query(
      Schema.travelRoutes,
      where: 'dynasty_id = ?',
      whereArgs: [dynastyId],
      orderBy: 'is_custom, id',
    );
    return rows.map(TravelRoute.fromRow).toList();
  }

  Future<TravelRoute> getById(int id) async {
    final rows = await _db.query(
      Schema.travelRoutes,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) throw StateError('TravelRoute $id not found');
    return TravelRoute.fromRow(rows.first);
  }

  Future<List<RouteStop>> getStops(int routeId) async {
    final rows = await _db.query(
      Schema.routeStops,
      where: 'route_id = ?',
      whereArgs: [routeId],
      orderBy: 'order_index',
    );
    return rows.map(RouteStop.fromRow).toList();
  }

  Future<int> insert(Map<String, dynamic> route) async {
    return _db.insert(Schema.travelRoutes, route);
  }

  Future<void> insertAll(List<Map<String, dynamic>> entries) async {
    final batch = _db.batch();
    for (final entry in entries) {
      batch.insert(Schema.travelRoutes, entry);
    }
    await batch.commit(noResult: true);
  }

  Future<int> insertStop(Map<String, dynamic> stop) async {
    return _db.insert(Schema.routeStops, stop);
  }

  Future<void> insertStops(List<Map<String, dynamic>> entries) async {
    final batch = _db.batch();
    for (final entry in entries) {
      batch.insert(Schema.routeStops, entry);
    }
    await batch.commit(noResult: true);
  }

  Future<void> deleteRoute(int id) async {
    await _db.delete(
      Schema.routeStops,
      where: 'route_id = ?',
      whereArgs: [id],
    );
    await _db.delete(
      Schema.travelRoutes,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
