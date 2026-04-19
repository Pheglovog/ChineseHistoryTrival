import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/database/app_database.dart';
import 'database_provider.dart';
import 'current_dynasty_provider.dart';

/// Reactive locations list for the current dynasty
final locationsByDynastyProvider = StreamProvider<List<AncientLocation>>((ref) {
  final db = ref.watch(databaseProvider);
  final dynastyId = ref.watch(currentDynastyIdProvider);
  return db.ancientLocationDao.watchByDynasty(dynastyId);
});

/// Locations filtered by admin level
final locationsByDynastyAndLevelProvider =
    StreamProvider.family<List<AncientLocation>, String>((ref, adminLevel) {
  final db = ref.watch(databaseProvider);
  final dynastyId = ref.watch(currentDynastyIdProvider);
  return db.ancientLocationDao.watchByDynastyAndLevel(dynastyId, adminLevel);
});

/// Children of a specific location
final locationChildrenProvider =
    StreamProvider.family<List<AncientLocation>, int>((ref, parentId) {
  final db = ref.watch(databaseProvider);
  return db.ancientLocationDao.watchChildren(parentId);
});
