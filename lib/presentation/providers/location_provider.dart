import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/ancient_location.dart';
import 'database_provider.dart';
import 'current_dynasty_provider.dart';

final locationsByDynastyProvider = FutureProvider<List<AncientLocation>>((ref) async {
  final db = ref.watch(databaseProvider);
  final dynastyId = ref.watch(currentDynastyIdProvider);
  final dao = await db.ancientLocationDao;
  return dao.getByDynasty(dynastyId);
});

final locationsByDynastyAndLevelProvider =
    FutureProvider.family<List<AncientLocation>, String>((ref, adminLevel) async {
  final db = ref.watch(databaseProvider);
  final dynastyId = ref.watch(currentDynastyIdProvider);
  final dao = await db.ancientLocationDao;
  return dao.getByDynastyAndLevel(dynastyId, adminLevel);
});

final locationChildrenProvider =
    FutureProvider.family<List<AncientLocation>, int>((ref, parentId) async {
  final db = ref.watch(databaseProvider);
  final dao = await db.ancientLocationDao;
  return dao.getChildren(parentId);
});
