import 'package:sqflite/sqflite.dart';

import '../../../domain/entities/browse_history.dart';
import '../database/schema.dart';

class BrowseHistoryDao {
  final Database _db;

  BrowseHistoryDao(this._db);

  Future<List<BrowseHistory>> getAll({int limit = 50}) async {
    final rows = await _db.query(
      Schema.browseHistory,
      orderBy: 'visited_at DESC',
      limit: limit,
    );
    return rows.map(BrowseHistory.fromRow).toList();
  }

  Future<void> upsert(int locationId, int dynastyId) async {
    await _db.insert(
      Schema.browseHistory,
      {
        'location_id': locationId,
        'dynasty_id': dynastyId,
        'visited_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> clearAll() async {
    await _db.delete(Schema.browseHistory);
  }

  Future<int> count() async {
    final result = await _db.rawQuery(
      'SELECT COUNT(*) as count FROM ${Schema.browseHistory}',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
