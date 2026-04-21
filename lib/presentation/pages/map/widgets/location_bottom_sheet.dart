import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// 标记点击底部弹窗 - 显示地点详情
class LocationBottomSheet extends StatelessWidget {
  final dynamic location;

  const LocationBottomSheet({
    super.key,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Location name
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              location.name,
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Admin level badge
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildLevelBadge(location.adminLevel.toString()),
          ),
          const SizedBox(height: 16),

          // Details
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildDetails(location),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildLevelBadge(String level) {
    final labels = {'zhou': '州', 'jun': '郡', 'xian': '县'};
    final label = labels[level] ?? level;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary, width: 0.5),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 12,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildDetails(dynamic loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (loc.description != null)
          _buildDetailRow('简介', loc.description),
        if (loc.historicalSignificance != null)
          _buildDetailRow('历史意义', loc.historicalSignificance),
        if (loc.alias != null) _buildDetailRow('别名', loc.alias),
      ],
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    if (value == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
