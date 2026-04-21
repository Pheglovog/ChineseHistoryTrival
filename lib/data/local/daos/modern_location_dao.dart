import 'package:sqflite/sqflite.dart';

import '../../../domain/entities/modern_location.dart';
import '../database/schema.dart';

class ModernLocationDao {
  final Database _db;

  ModernLocationDao(this._db);

  Future<List<ModernLocation>> getByName(String name) async {
    final rows = await _db.query(
      Schema.modernLocations,
      where: 'name LIKE ?',
      whereArgs: ['%$name%'],
    );
    return rows.map(ModernLocation.fromRow).toList();
  }

  Future<ModernLocation?> getByNameExact(String name) async {
    final rows = await _db.query(
      Schema.modernLocations,
      where: 'name = ?',
      whereArgs: [name],
    );
    if (rows.isEmpty) return null;
    return ModernLocation.fromRow(rows.first);
  }

  Future<List<ModernLocation>> getByCoordinateRange(
    double minLat,
    double maxLat,
    double minLng,
    double maxLng,
  ) async {
    final rows = await _db.query(
      Schema.modernLocations,
      where: 'latitude >= ? AND latitude <= ? AND longitude >= ? AND longitude <= ?',
      whereArgs: [minLat, maxLat, minLng, maxLng],
    );
    return rows.map(ModernLocation.fromRow).toList();
  }

  Future<int> insert(Map<String, dynamic> location) async {
    return _db.insert(Schema.modernLocations, location);
  }

  Future<void> insertAll(List<Map<String, dynamic>> entries) async {
    final batch = _db.batch();
    for (final entry in entries) {
      batch.insert(Schema.modernLocations, entry);
    }
    await batch.commit(noResult: true);
  }
}
