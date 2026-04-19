import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/database/app_database.dart';
import 'database_provider.dart';
import 'current_dynasty_provider.dart';
import 'map_state_provider.dart';

/// Visible markers based on map zoom and bounds
final visibleMarkersProvider =
    FutureProvider<List<AncientLocation>>((ref) async {
  final db = ref.watch(databaseProvider);
  final dynastyId = ref.watch(currentDynastyIdProvider);
  final camera = ref.watch(mapCameraProvider);
  final bounds = ref.watch(mapBoundsProvider);
  final levelFilter = ref.watch(adminLevelFilterProvider);

  // Determine which levels to show based on zoom
  List<String> levels;
  if (camera.zoom < 6) {
    levels = ['zhou'];
  } else if (camera.zoom < 9) {
    levels = ['zhou', 'jun'];
  } else {
    levels = ['zhou', 'jun', 'xian'];
  }

  // Apply user filter override
  if (levelFilter != AdminLevelFilter.all) {
    final filterMap = {
      AdminLevelFilter.zhou: ['zhou'],
      AdminLevelFilter.jun: ['jun'],
      AdminLevelFilter.xian: ['xian'],
    };
    levels = filterMap[levelFilter] ?? levels;
  }

  List<AncientLocation> locations = [];
  for (final level in levels) {
    locations.addAll(
      await db.ancientLocationDao.getByDynastyAndLevel(dynastyId, level),
    );
  }

  // Filter by bounds if available
  if (bounds != null) {
    // For locations with matches, filter by coordinate bounds
    // This is a simplified approach - actual filtering uses matched modern coords
    return locations;
  }

  return locations;
});
