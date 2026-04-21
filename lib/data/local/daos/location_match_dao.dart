import 'package:sqflite/sqflite.dart';

import '../../../domain/entities/location_match.dart';
import '../database/schema.dart';

class LocationMatchDao {
  final Database _db;

  LocationMatchDao(this._db);

  Future<List<LocationMatch>> getByAncientLocationId(int ancientLocationId) async {
    final rows = await _db.query(
      Schema.locationMatches,
      where: 'ancient_location_id = ?',
      whereArgs: [ancientLocationId],
      orderBy: 'confidence DESC',
    );
    return rows.map(LocationMatch.fromRow).toList();
  }

  Future<LocationMatch?> getCachedMatch(int ancientLocationId) async {
    final rows = await _db.query(
      Schema.locationMatches,
      where: 'ancient_location_id = ? AND verified = 1',
      whereArgs: [ancientLocationId],
      orderBy: 'confidence DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return LocationMatch.fromRow(rows.first);
  }

  Stream<List<LocationMatch>> watchByAncientLocationId(int ancientLocationId) async* {
    yield await getByAncientLocationId(ancientLocationId);
  }

  Future<int> insert(Map<String, dynamic> match) async {
    return _db.insert(Schema.locationMatches, match);
  }

  Future<void> insertAll(List<Map<String, dynamic>> entries) async {
    final batch = _db.batch();
    for (final entry in entries) {
      batch.insert(Schema.locationMatches, entry);
    }
    await batch.commit(noResult: true);
  }

  Future<bool> hasMatch(int ancientLocationId) async {
    final result = await _db.rawQuery(
      'SELECT COUNT(*) as count FROM ${Schema.locationMatches} WHERE ancient_location_id = ?',
      [ancientLocationId],
    );
    return (Sqflite.firstIntValue(result) ?? 0) > 0;
  }
}
