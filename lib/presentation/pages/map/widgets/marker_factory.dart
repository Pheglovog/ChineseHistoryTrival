import 'package:amap_map/amap_map.dart';
import 'package:x_amap_base/x_amap_base.dart';
import 'package:flutter/material.dart';

import '../../../../domain/entities/ancient_location.dart';

class MarkerFactory {
  static Marker createMarker({
    required AncientLocation location,
    bool showModernName = false,
    VoidCallback? onTap,
  }) {
    final adminLevel = location.adminLevel.toString();
    final levelLabel = _getLevelLabel(adminLevel);

    return Marker(
      position: LatLng(34.0, 108.0),
      infoWindow: InfoWindow(
        title: location.name,
        snippet: levelLabel,
      ),
      onTap: onTap != null ? (_) => onTap() : null,
    );
  }

  /// Create a polyline connecting route stops with gold style.
  static Polyline createRoutePolyline({
    required List<LatLng> points,
  }) {
    return Polyline(
      points: points,
      width: 4,
      color: Colors.amber,
    );
  }

  /// Create numbered stop markers for a route.
  static List<Marker> createStopMarkers({
    required List<AncientLocation> stops,
    VoidCallback Function(int index)? onStopTap,
  }) {
    return stops.asMap().entries.map((entry) {
      final index = entry.key;
      final stop = entry.value;
      return Marker(
        position: LatLng(34.0, 108.0),
        infoWindow: InfoWindow(
          title: '${index + 1}. ${stop.name}',
          snippet: stop.description,
        ),
        onTap: onStopTap != null ? (_) => onStopTap(index) : null,
      );
    }).toList();
  }

  static String _getLevelLabel(String level) {
    switch (level) {
      case 'zhou':
        return '\u5dde';
      case 'jun':
        return '\u90e1';
      case 'xian':
        return '\u53bf';
      default:
        return '';
    }
  }
}
