import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Map camera position state
class MapCameraState {
  final double latitude;
  final double longitude;
  final double zoom;
  final double tilt;
  final double bearing;

  const MapCameraState({
    this.latitude = 34.26,
    this.longitude = 108.93,
    this.zoom = 5.0,
    this.tilt = 0,
    this.bearing = 0,
  });

  MapCameraState copyWith({
    double? latitude,
    double? longitude,
    double? zoom,
    double? tilt,
    double? bearing,
  }) {
    return MapCameraState(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      zoom: zoom ?? this.zoom,
      tilt: tilt ?? this.tilt,
      bearing: bearing ?? this.bearing,
    );
  }
}

/// Visible map bounds
class MapBounds {
  final double northEastLat;
  final double northEastLng;
  final double southWestLat;
  final double southWestLng;

  const MapBounds({
    required this.northEastLat,
    required this.northEastLng,
    required this.southWestLat,
    required this.southWestLng,
  });
}

/// Map state provider
final mapCameraProvider =
    StateProvider<MapCameraState>((ref) => const MapCameraState());
final mapBoundsProvider = StateProvider<MapBounds?>((ref) => null);

/// Admin level filter for map
enum AdminLevelFilter { all, zhou, jun, xian }

final adminLevelFilterProvider =
    StateProvider<AdminLevelFilter>((ref) => AdminLevelFilter.all);
