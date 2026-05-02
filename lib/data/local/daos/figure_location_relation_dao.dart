import 'package:sqflite/sqflite.dart';

import '../../../domain/entities/figure_location_relation.dart';
import '../database/schema.dart';

class FigureLocationRelationDao {
  final Database _db;

  FigureLocationRelationDao(this._db);

  Future<List<FigureLocationRelation>> getByFigureId(int figureId) async {
    final rows = await _db.query(
      Schema.figureLocationRelations,
      where: 'figure_id = ?',
      whereArgs: [figureId],
    );
    return rows.map(FigureLocationRelation.fromRow).toList();
  }

  Future<List<FigureLocationRelation>> getByLocationId(int locationId) async {
    final rows = await _db.query(
      Schema.figureLocationRelations,
      where: 'location_id = ?',
      whereArgs: [locationId],
    );
    return rows.map(FigureLocationRelation.fromRow).toList();
  }

  Future<int> insert(Map<String, dynamic> relation) async {
    return _db.insert(Schema.figureLocationRelations, relation);
  }

  Future<void> insertAll(List<Map<String, dynamic>> entries) async {
    final batch = _db.batch();
    for (final entry in entries) {
      batch.insert(Schema.figureLocationRelations, entry);
    }
    await batch.commit(noResult: true);
  }
}
