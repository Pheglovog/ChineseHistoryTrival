import 'package:sqflite/sqflite.dart';

import '../../../domain/entities/user_favorite.dart';
import '../database/schema.dart';

class UserFavoriteDao {
  final Database _db;

  UserFavoriteDao(this._db);

  Future<List<UserFavorite>> getByDynasty(int dynastyId) async {
    final rows = await _db.query(
      Schema.userFavorites,
      where: 'dynasty_id = ?',
      whereArgs: [dynastyId],
      orderBy: 'created_at DESC',
    );
    return rows.map(UserFavorite.fromRow).toList();
  }

  Future<List<UserFavorite>> getAll() async {
    final rows = await _db.query(
      Schema.userFavorites,
      orderBy: 'created_at DESC',
    );
    return rows.map(UserFavorite.fromRow).toList();
  }

  Future<bool> isFavorite(int locationId) async {
    final result = await _db.rawQuery(
      'SELECT COUNT(*) as count FROM ${Schema.userFavorites} WHERE location_id = ?',
      [locationId],
    );
    return (Sqflite.firstIntValue(result) ?? 0) > 0;
  }

  Future<int> addFavorite(int locationId, int dynastyId) async {
    return _db.insert(Schema.userFavorites, {
      'location_id': locationId,
      'dynasty_id': dynastyId,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> removeFavorite(int locationId) async {
    await _db.delete(
      Schema.userFavorites,
      where: 'location_id = ?',
      whereArgs: [locationId],
    );
  }

  Future<int> countByDynasty(int dynastyId) async {
    final result = await _db.rawQuery(
      'SELECT COUNT(*) as count FROM ${Schema.userFavorites} WHERE dynasty_id = ?',
      [dynastyId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
