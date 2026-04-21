import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/ancient_location.dart';
import 'database_provider.dart';
import 'current_dynasty_provider.dart';
import 'map_state_provider.dart';

final visibleMarkersProvider =
    FutureProvider<List<AncientLocation>>((ref) async {
  final db = ref.watch(databaseProvider);
  final dynastyId = ref.watch(currentDynastyIdProvider);
  final camera = ref.watch(mapCameraProvider);
  final levelFilter = ref.watch(adminLevelFilterProvider);

  List<String> levels;
  if (camera.zoom < 6) {
    levels = ['zhou'];
  } else if (camera.zoom < 9) {
    levels = ['zhou', 'jun'];
  } else {
    levels = ['zhou', 'jun', 'xian'];
  }

  if (levelFilter != AdminLevelFilter.all) {
    final filterMap = {
      AdminLevelFilter.zhou: ['zhou'],
      AdminLevelFilter.jun: ['jun'],
      AdminLevelFilter.xian: ['xian'],
    };
    levels = filterMap[levelFilter] ?? levels;
  }

  final dao = await db.ancientLocationDao;
  List<AncientLocation> locations = [];
  for (final level in levels) {
    locations.addAll(await dao.getByDynastyAndLevel(dynastyId, level));
  }

  return locations;
});
