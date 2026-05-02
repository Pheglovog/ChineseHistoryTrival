import 'package:sqflite/sqflite.dart';

import '../../../domain/entities/history_card.dart';
import '../database/schema.dart';

class HistoryCardDao {
  final Database _db;

  HistoryCardDao(this._db);

  Future<List<HistoryCard>> getByDynasty(int dynastyId) async {
    final rows = await _db.query(
      Schema.historyCards,
      where: 'dynasty_id = ?',
      whereArgs: [dynastyId],
      orderBy: 'id',
    );
    return rows.map(HistoryCard.fromRow).toList();
  }

  Future<List<HistoryCard>> getByDynastyAndCategory(
    int dynastyId,
    String category,
  ) async {
    final rows = await _db.query(
      Schema.historyCards,
      where: 'dynasty_id = ? AND category = ?',
      whereArgs: [dynastyId, category],
    );
    return rows.map(HistoryCard.fromRow).toList();
  }

  Future<HistoryCard> getById(int id) async {
    final rows = await _db.query(
      Schema.historyCards,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) throw StateError('HistoryCard $id not found');
    return HistoryCard.fromRow(rows.first);
  }

  Future<HistoryCard> getCardByDayOffset(int dynastyId, int dayOffset) async {
    final cards = await getByDynasty(dynastyId);
    if (cards.isEmpty) throw StateError('No history cards found');
    final index = dayOffset % cards.length;
    return cards[index];
  }

  Future<int> insert(Map<String, dynamic> card) async {
    return _db.insert(Schema.historyCards, card);
  }

  Future<void> insertAll(List<Map<String, dynamic>> entries) async {
    final batch = _db.batch();
    for (final entry in entries) {
      batch.insert(Schema.historyCards, entry);
    }
    await batch.commit(noResult: true);
  }

  Future<int> countByDynasty(int dynastyId) async {
    final result = await _db.rawQuery(
      'SELECT COUNT(*) as count FROM ${Schema.historyCards} WHERE dynasty_id = ?',
      [dynastyId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
