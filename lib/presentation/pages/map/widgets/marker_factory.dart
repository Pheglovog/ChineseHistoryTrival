import 'package:amap_map/amap_map.dart';
import '../../../../core/theme/app_colors.dart';

/// 根据行政级别生成不同样式的地图标记
class MarkerFactory {
  static AMapMarker createMarker({
    required dynamic location,
    VoidCallback? onTap,
  }) {
    final adminLevel = location.adminLevel.toString();
    final color = _getColorForLevel(adminLevel);
    final size = _getSizeForLevel(adminLevel);

    return AMapMarker(
      position: LatLng(
        location.latitude ?? 34.0,
        location.longitude ?? 108.0,
      ),
      infoWindow: InfoWindow(
        title: location.name,
        snippet: _getLevelLabel(adminLevel),
      ),
      icon: _createIconDescriptor(color, size),
      extraInfo: {'locationId': location.id},
    );
  }

  static Color _getColorForLevel(String level) {
    switch (level) {
      case 'zhou':
        return AppColors.primary; // 朱红
      case 'jun':
        return AppColors.secondary; // 苍绿
      case 'xian':
        return AppColors.ink; // 墨色
      default:
        return AppColors.gold;
    }
  }

  static double _getSizeForLevel(String level) {
    switch (level) {
      case 'zhou':
        return 48.0;
      case 'jun':
        return 36.0;
      case 'xian':
        return 28.0;
      default:
        return 32.0;
    }
  }

  static String _getLevelLabel(String level) {
    switch (level) {
      case 'zhou':
        return '州';
      case 'jun':
        return '郡';
      case 'xian':
        return '县';
      default:
        return '';
    }
  }

  static BitmapDescriptor _createIconDescriptor(Color color, double size) {
    // Use default marker with color tinting
    // The actual bitmap creation depends on amap_map API
    return BitmapDescriptor.defaultMarkerWithHue(
      _colorToHue(color),
    );
  }

  static double _colorToHue(Color color) {
    // Simplified: map our colors to marker hues
    if (color == AppColors.primary) return BitmapDescriptor.hueRed;
    if (color == AppColors.secondary) return 120.0; // Green
    return 0.0; // Default red
  }
}
