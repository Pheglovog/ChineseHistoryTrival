import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_favorite.dart';
import '../../domain/entities/browse_history.dart';
import 'database_provider.dart';
import 'current_dynasty_provider.dart';

final favoritesProvider =
    FutureProvider<List<UserFavorite>>((ref) async {
  final db = ref.watch(databaseProvider);
  final dynastyId = ref.watch(currentDynastyIdProvider);
  final dao = await db.userFavoriteDao;
  return dao.getByDynasty(dynastyId);
});

final allFavoritesProvider =
    FutureProvider<List<UserFavorite>>((ref) async {
  final db = ref.watch(databaseProvider);
  final dao = await db.userFavoriteDao;
  return dao.getAll();
});

final isFavoriteProvider =
    FutureProvider.family<bool, int>((ref, locationId) async {
  final db = ref.watch(databaseProvider);
  final dao = await db.userFavoriteDao;
  return dao.isFavorite(locationId);
});

final browseHistoryProvider =
    FutureProvider<List<BrowseHistory>>((ref) async {
  final db = ref.watch(databaseProvider);
  final dao = await db.browseHistoryDao;
  return dao.getAll();
});
