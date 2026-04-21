import 'package:amap_map/amap_map.dart';
import 'package:x_amap_base/x_amap_base.dart';
import 'package:flutter/material.dart';

class MarkerFactory {
  static Marker createMarker({
    required dynamic location,
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
