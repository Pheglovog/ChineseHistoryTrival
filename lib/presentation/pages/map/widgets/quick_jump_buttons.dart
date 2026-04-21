import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../providers/map_state_provider.dart';

/// 快速跳转按钮 - 长安、洛阳等著名城市
class QuickJumpButtons extends ConsumerWidget {
  const QuickJumpButtons({super.key});

  static const List<_QuickJump> _jumps = [
    _QuickJump('长安', 34.27, 108.95),
    _QuickJump('洛阳', 34.62, 112.45),
    _QuickJump('临淄', 36.83, 118.31),
    _QuickJump('成都', 30.57, 104.07),
    _QuickJump('宛', 33.00, 112.53),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _jumps.map((jump) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(20),
            color: AppColors.surface,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _jumpTo(context, ref, jump),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.5),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  jump.name,
                  style: const TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 12,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _jumpTo(BuildContext context, WidgetRef ref, _QuickJump jump) {
    // Update camera state
    ref.read(mapCameraProvider.notifier).state = MapCameraState(
      latitude: jump.lat,
      longitude: jump.lng,
      zoom: 10,
    );

    // The map controller would handle the actual animation
    // via AMapController.animateCamera()
  }
}

class _QuickJump {
  final String name;
  final double lat;
  final double lng;

  const _QuickJump(this.name, this.lat, this.lng);
}
