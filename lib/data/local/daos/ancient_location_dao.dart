import 'package:sqflite/sqflite.dart';

import '../../../domain/entities/ancient_location.dart';
import '../database/schema.dart';

class AncientLocationDao {
  final Database _db;

  AncientLocationDao(this._db);

  Stream<List<AncientLocation>> watchByDynasty(int dynastyId) async* {
    yield await getByDynasty(dynastyId);
  }

  Stream<List<AncientLocation>> watchByDynastyAndLevel(
    int dynastyId,
    String adminLevel,
  ) async* {
    yield await getByDynastyAndLevel(dynastyId, adminLevel);
  }

  Stream<List<AncientLocation>> watchChildren(int parentLocationId) async* {
    yield await getChildren(parentLocationId);
  }

  Future<List<AncientLocation>> getByDynasty(int dynastyId) async {
    final rows = await _db.query(
      Schema.ancientLocations,
      where: 'dynasty_id = ?',
      whereArgs: [dynastyId],
    );
    return rows.map(AncientLocation.fromRow).toList();
  }

  Future<List<AncientLocation>> getByDynastyAndLevel(
    int dynastyId,
    String adminLevel,
  ) async {
    final rows = await _db.query(
      Schema.ancientLocations,
      where: 'dynasty_id = ? AND admin_level = ?',
      whereArgs: [dynastyId, adminLevel],
    );
    return rows.map(AncientLocation.fromRow).toList();
  }

  Future<List<AncientLocation>> getChildren(int parentLocationId) async {
    final rows = await _db.query(
      Schema.ancientLocations,
      where: 'parent_location_id = ?',
      whereArgs: [parentLocationId],
    );
    return rows.map(AncientLocation.fromRow).toList();
  }

  Future<AncientLocation> getById(int id) async {
    final rows = await _db.query(
      Schema.ancientLocations,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) throw StateError('AncientLocation $id not found');
    return AncientLocation.fromRow(rows.first);
  }

  Future<int> insert(Map<String, dynamic> location) async {
    return _db.insert(Schema.ancientLocations, location);
  }

  Future<void> insertAll(List<Map<String, dynamic>> entries) async {
    final batch = _db.batch();
    for (final entry in entries) {
      batch.insert(Schema.ancientLocations, entry);
    }
    await batch.commit(noResult: true);
  }

  Future<int> countByDynasty(int dynastyId) async {
    final result = await _db.rawQuery(
      'SELECT COUNT(*) as count FROM ${Schema.ancientLocations} WHERE dynasty_id = ?',
      [dynastyId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> countByDynastyAndLevel(int dynastyId, String adminLevel) async {
    final result = await _db.rawQuery(
      'SELECT COUNT(*) as count FROM ${Schema.ancientLocations} WHERE dynasty_id = ? AND admin_level = ?',
      [dynastyId, adminLevel],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<AncientLocation>> searchByName(String query, {int dynastyId = 1}) async {
    final rows = await _db.query(
      Schema.ancientLocations,
      where: 'dynasty_id = ? AND name LIKE ?',
      whereArgs: [dynastyId, '%$query%'],
    );
    return rows.map(AncientLocation.fromRow).toList();
  }

  /// Find ancient locations across all dynasties that share the same modern location.
  /// Used for historical change comparison across dynasties.
  Future<List<Map<String, dynamic>>> getByModernLocationAcrossDynasties(
    int modernLocationId,
  ) async {
    return _db.rawQuery('''
      SELECT al.*, d.name as dynasty_name, d.start_year, d.end_year
      FROM ${Schema.ancientLocations} al
      INNER JOIN ${Schema.locationMatches} lm ON al.id = lm.ancient_location_id
      INNER JOIN ${Schema.dynasties} d ON al.dynasty_id = d.id
      WHERE lm.modern_location_id = ?
      ORDER BY d.start_year
    ''', [modernLocationId]);
  }

  /// Find locations across other dynasties with the same name or alias.
  /// Used for simple historical change comparison when location_matches data is unavailable.
  Future<List<Map<String, dynamic>>> getByNameAcrossDynasties(
    String name, {
    int? excludeDynastyId,
  }) async {
    var where = '(al.name = ? OR al.alias = ?)';
    final args = <dynamic>[name, name];
    if (excludeDynastyId != null) {
      where += ' AND al.dynasty_id != ?';
      args.add(excludeDynastyId);
    }
    return _db.rawQuery('''
      SELECT al.*, d.name as dynasty_name, d.start_year, d.end_year
      FROM ${Schema.ancientLocations} al
      INNER JOIN ${Schema.dynasties} d ON al.dynasty_id = d.id
      WHERE $where
      ORDER BY d.start_year
    ''', args);
  }

  /// Find ancient locations across all dynasties near given coordinates.
  Future<List<Map<String, dynamic>>> getByCoordinatesAcrossDynasties(
    double lat,
    double lng, {
    double radiusDegrees = 0.5,
  }) async {
    return _db.rawQuery('''
      SELECT al.*, d.name as dynasty_name, d.start_year, d.end_year,
             ml.name as modern_name
      FROM ${Schema.ancientLocations} al
      INNER JOIN ${Schema.locationMatches} lm ON al.id = lm.ancient_location_id
      INNER JOIN ${Schema.modernLocations} ml ON lm.modern_location_id = ml.id
      INNER JOIN ${Schema.dynasties} d ON al.dynasty_id = d.id
      WHERE ml.latitude BETWEEN ? AND ?
        AND ml.longitude BETWEEN ? AND ?
      ORDER BY d.start_year
    ''', [
      lat - radiusDegrees,
      lat + radiusDegrees,
      lng - radiusDegrees,
      lng + radiusDegrees,
    ]);
  }
}
