import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amap_map/amap_map.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/classical_app_bar.dart';
import '../../providers/map_state_provider.dart';
import '../../providers/visible_markers_provider.dart';
import '../../providers/database_provider.dart';
import 'widgets/marker_factory.dart';
import 'widgets/location_bottom_sheet.dart';
import 'widgets/quick_jump_buttons.dart';
import 'widgets/map_search_bar.dart';
import 'widgets/admin_level_chips.dart';

/// 汉代地图页面 - 高德地图基础渲染
class HanMapPage extends ConsumerStatefulWidget {
  const HanMapPage({super.key});

  @override
  ConsumerState<HanMapPage> createState() => _HanMapPageState();
}

class _HanMapPageState extends ConsumerState<HanMapPage> {
  AMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    final markersAsync = ref.watch(visibleMarkersProvider);

    return Scaffold(
      appBar: const ClassicalAppBar(title: '汉代地图'),
      body: Stack(
        children: [
          // Map
          AMapWidget(
            initialCameraPosition: const CameraPosition(
              target: LatLng(34.5, 108.0),
              zoom: 5,
            ),
            onMapCreated: _onMapCreated,
            onCameraMoveEnd: _onCameraMoveEnd,
            markers: markersAsync.when(
              data: (locations) => _buildMarkers(locations),
              loading: () => const [],
              error: (_, __) => const [],
            ),
            onMarkerClick: _onMarkerClick,
          ),

          // Search bar overlay
          const Positioned(
            top: 8,
            left: 16,
            right: 16,
            child: MapSearchBar(),
          ),

          // Admin level filter chips
          const Positioned(
            top: 60,
            left: 16,
            child: AdminLevelChips(),
          ),

          // Quick jump buttons
          const Positioned(
            bottom: 24,
            right: 16,
            child: QuickJumpButtons(),
          ),
        ],
      ),
    );
  }

  void _onMapCreated(AMapController controller) {
    _mapController = controller;
  }

  void _onCameraMoveEnd(CameraPosition position) {
    ref.read(mapCameraProvider.notifier).state = MapCameraState(
      latitude: position.target.latitude,
      longitude: position.target.longitude,
      zoom: position.zoom,
    );

    // Update visible bounds if controller available
    _mapController?.getVisibleRegion().then((bounds) {
      if (bounds != null && mounted) {
        ref.read(mapBoundsProvider.notifier).state = MapBounds(
          northEastLat: bounds.northeast.latitude,
          northEastLng: bounds.northeast.longitude,
          southWestLat: bounds.southwest.latitude,
          southWestLng: bounds.southwest.longitude,
        );
      }
    });
  }

  List<AMapMarker> _buildMarkers(List<dynamic> locations) {
    return locations.map((loc) {
      // Get matched modern location for coordinates
      // Simplified: use marker factory
      return MarkerFactory.createMarker(
        location: loc,
        onTap: () => _showLocationDetail(loc),
      );
    }).toList();
  }

  void _onMarkerClick(AMapMarker marker) {
    final locId = marker.extraInfo?['locationId'] as int?;
    if (locId != null) {
      _showLocationById(locId);
    }
  }

  void _showLocationDetail(dynamic location) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => LocationBottomSheet(location: location),
    );
  }

  void _showLocationById(int id) async {
    final db = ref.read(databaseProvider);
    final loc = await db.ancientLocationDao.getById(id);
    if (mounted) {
      _showLocationDetail(loc);
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
