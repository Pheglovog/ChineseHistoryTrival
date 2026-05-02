import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amap_map/amap_map.dart';
import 'package:x_amap_base/x_amap_base.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/ancient_location.dart';
import '../../providers/map_state_provider.dart';
import '../../providers/visible_markers_provider.dart';
import 'widgets/marker_factory.dart';
import 'widgets/location_bottom_sheet.dart';
import 'widgets/quick_jump_buttons.dart';
import 'widgets/map_search_bar.dart';
import 'widgets/admin_level_chips.dart';

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
    final showModernName = ref.watch(showModernNameProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('\u6c49\u4ee3\u5730\u56fe'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        actions: [
          // Toggle dual labels
          IconButton(
            icon: Icon(
              showModernName
                  ? Icons.label_important
                  : Icons.label_outline,
              color: showModernName ? AppColors.gold : AppColors.textHint,
              size: 22,
            ),
            onPressed: () {
              ref.read(showModernNameProvider.notifier).state =
                  !showModernName;
            },
            tooltip: '古今对照',
          ),
        ],
      ),
      body: Stack(
        children: [
          AMapWidget(
            initialCameraPosition: const CameraPosition(
              target: LatLng(34.5, 108.0),
              zoom: 5,
            ),
            onMapCreated: _onMapCreated,
            onCameraMoveEnd: _onCameraMoveEnd,
            markers: markersAsync.when(
              data: (locations) =>
                  _buildMarkers(locations, showModernName: showModernName)
                      .toSet(),
              loading: () => <Marker>{},
              error: (_, _) => <Marker>{},
            ),
          ),
          const Positioned(
            top: 8,
            left: 16,
            right: 16,
            child: MapSearchBar(),
          ),
          const Positioned(
            top: 60,
            left: 16,
            child: AdminLevelChips(),
          ),
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
  }

  List<Marker> _buildMarkers(List<AncientLocation> locations,
      {bool showModernName = false}) {
    return locations.map((loc) {
      return MarkerFactory.createMarker(
        location: loc,
        showModernName: showModernName,
        onTap: () => _showLocationDetail(loc),
      );
    }).toList();
  }

  void _showLocationDetail(AncientLocation location) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => LocationBottomSheet(location: location),
    );
  }

  @override
  void dispose() {
    _mapController?.disponse();
    super.dispose();
  }
}
