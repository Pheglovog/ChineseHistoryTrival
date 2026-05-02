import 'package:sqflite/sqflite.dart';

import '../../../domain/entities/historical_figure.dart';
import '../database/schema.dart';

class HistoricalFigureDao {
  final Database _db;

  HistoricalFigureDao(this._db);

  Future<List<HistoricalFigure>> getByDynasty(int dynastyId) async {
    final rows = await _db.query(
      Schema.historicalFigures,
      where: 'dynasty_id = ?',
      whereArgs: [dynastyId],
      orderBy: 'category, id',
    );
    return rows.map(HistoricalFigure.fromRow).toList();
  }

  Future<HistoricalFigure> getById(int id) async {
    final rows = await _db.query(
      Schema.historicalFigures,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) throw StateError('HistoricalFigure $id not found');
    return HistoricalFigure.fromRow(rows.first);
  }

  Future<List<HistoricalFigure>> getByLocationId(int locationId) async {
    final rows = await _db.rawQuery('''
      SELECT f.* FROM ${Schema.historicalFigures} f
      INNER JOIN ${Schema.figureLocationRelations} r ON f.id = r.figure_id
      WHERE r.location_id = ?
      ORDER BY f.category, f.id
    ''', [locationId]);
    return rows.map(HistoricalFigure.fromRow).toList();
  }

  Future<List<HistoricalFigure>> getByDynastyAndCategory(
    int dynastyId,
    String category,
  ) async {
    final rows = await _db.query(
      Schema.historicalFigures,
      where: 'dynasty_id = ? AND category = ?',
      whereArgs: [dynastyId, category],
    );
    return rows.map(HistoricalFigure.fromRow).toList();
  }

  Future<int> insert(Map<String, dynamic> figure) async {
    return _db.insert(Schema.historicalFigures, figure);
  }

  Future<void> insertAll(List<Map<String, dynamic>> entries) async {
    final batch = _db.batch();
    for (final entry in entries) {
      batch.insert(Schema.historicalFigures, entry);
    }
    await batch.commit(noResult: true);
  }

  Future<int> countByDynasty(int dynastyId) async {
    final result = await _db.rawQuery(
      'SELECT COUNT(*) as count FROM ${Schema.historicalFigures} WHERE dynasty_id = ?',
      [dynastyId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
