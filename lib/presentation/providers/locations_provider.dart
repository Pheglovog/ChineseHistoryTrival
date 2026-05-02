import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/ancient_location.dart';
import 'database_provider.dart';
import 'current_dynasty_provider.dart';

final zhouListProvider = FutureProvider<List<AncientLocation>>((ref) async {
  final db = ref.watch(databaseProvider);
  final dynastyId = ref.watch(currentDynastyIdProvider);
  final dao = await db.ancientLocationDao;
  return dao.getByDynastyAndLevel(dynastyId, 'zhou');
});

final junListProvider =
    FutureProvider.family<List<AncientLocation>, int>((ref, parentLocationId) async {
  final db = ref.watch(databaseProvider);
  final dao = await db.ancientLocationDao;
  return dao.getChildren(parentLocationId);
});

final xianListProvider =
    FutureProvider.family<List<AncientLocation>, int>((ref, parentLocationId) async {
  final db = ref.watch(databaseProvider);
  final dao = await db.ancientLocationDao;
  return dao.getChildren(parentLocationId);
});

final locationCountsProvider =
    FutureProvider.family<int, String>((ref, adminLevel) async {
  final db = ref.watch(databaseProvider);
  final dynastyId = ref.watch(currentDynastyIdProvider);
  final dao = await db.ancientLocationDao;
  return dao.countByDynastyAndLevel(dynastyId, adminLevel);
});

/// Query locations across other dynasties with the same name.
final crossDynastyLocationsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((ref, name) async {
  final db = ref.watch(databaseProvider);
  final dynastyId = ref.watch(currentDynastyIdProvider);
  final dao = await db.ancientLocationDao;
  return dao.getByNameAcrossDynasties(name, excludeDynastyId: dynastyId);
});
