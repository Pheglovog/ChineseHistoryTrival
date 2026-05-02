import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/dynasty.dart';
import 'database_provider.dart';

final currentDynastyIdProvider = StateProvider<int>((ref) => 1);

final currentDynastyProvider = FutureProvider<Dynasty?>((ref) async {
  final db = ref.watch(databaseProvider);
  final dynastyId = ref.watch(currentDynastyIdProvider);
  final dao = await db.dynastyDao;
  final dynasties = await dao.getAllDynasties();
  return dynasties.where((d) => d.id == dynastyId).firstOrNull;
});

final allDynastiesProvider = FutureProvider<List<Dynasty>>((ref) async {
  final db = ref.watch(databaseProvider);
  final dao = await db.dynastyDao;
  return dao.getAllDynasties();
});
