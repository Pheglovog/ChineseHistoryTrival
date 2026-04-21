import 'package:sqflite/sqflite.dart';

import '../../../domain/entities/dynasty.dart';
import '../database/schema.dart';

class DynastyDao {
  final Database _db;

  DynastyDao(this._db);

  Future<List<Dynasty>> getAllDynasties() async {
    final rows = await _db.query(Schema.dynasties, orderBy: 'start_year');
    return rows.map(Dynasty.fromRow).toList();
  }

  Stream<List<Dynasty>> watchAllDynasties() async* {
    yield await getAllDynasties();
  }

  Future<Dynasty> getDynastyById(int id) async {
    final rows = await _db.query(
      Schema.dynasties,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) throw StateError('Dynasty $id not found');
    return Dynasty.fromRow(rows.first);
  }

  Future<int> insertDynasty(Map<String, dynamic> dynasty) async {
    return _db.insert(Schema.dynasties, dynasty);
  }

  Future<void> insertDynasties(List<Map<String, dynamic>> dynastiesList) async {
    final batch = _db.batch();
    for (final dynasty in dynastiesList) {
      batch.insert(Schema.dynasties, dynasty);
    }
    await batch.commit(noResult: true);
  }
}
