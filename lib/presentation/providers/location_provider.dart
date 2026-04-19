import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database_provider.dart';

/// Provides the list of zhou-level locations for dynasty 1 (Han).
final zhouListProvider = StreamProvider<List<AncientLocation>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.ancientLocationDao.watchByDynastyAndLevel(1, 'zhou');
});

/// Family provider for jun list by parent zhou ID.
final junListProvider =
    StreamProvider.family<List<AncientLocation>, int>((ref, parentLocationId) {
  final db = ref.watch(databaseProvider);
  return db.ancientLocationDao.watchChildren(parentLocationId);
});

/// Family provider for xian list by parent jun ID.
final xianListProvider =
    StreamProvider.family<List<AncientLocation>, int>((ref, parentLocationId) {
  final db = ref.watch(databaseProvider);
  return db.ancientLocationDao.watchChildren(parentLocationId);
});

/// Provider for location counts grouped by admin level for dynasty 1 (Han).
final locationCountsProvider =
    FutureProvider.family<int, String>((ref, adminLevel) async {
  final db = ref.watch(databaseProvider);
  final locations =
      await db.ancientLocationDao.getByDynastyAndLevel(1, adminLevel);
  return locations.length;
});
