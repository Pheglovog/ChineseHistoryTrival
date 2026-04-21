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

  Future<List<AncientLocation>> searchByName(String query, {int dynastyId = 1}) async {
    final rows = await _db.query(
      Schema.ancientLocations,
      where: 'dynasty_id = ? AND name LIKE ?',
      whereArgs: [dynastyId, '%$query%'],
    );
    return rows.map(AncientLocation.fromRow).toList();
  }
}
