import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/ancient_location.dart';
import 'database_provider.dart';

final zhouListProvider = FutureProvider<List<AncientLocation>>((ref) async {
  final db = ref.watch(databaseProvider);
  final dao = await db.ancientLocationDao;
  return dao.getByDynastyAndLevel(1, 'zhou');
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
  final dao = await db.ancientLocationDao;
  final locations = await dao.getByDynastyAndLevel(1, adminLevel);
  return locations.length;
});
