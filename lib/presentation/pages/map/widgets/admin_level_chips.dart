import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../providers/map_state_provider.dart';

/// 行政级别筛选芯片 - 全部/州/郡/县
class AdminLevelChips extends ConsumerWidget {
  const AdminLevelChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(adminLevelFilterProvider);

    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(24),
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: AdminLevelFilter.values.map((filter) {
            final isSelected = filter == currentFilter;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: ChoiceChip(
                label: Text(_getLabel(filter)),
                selected: isSelected,
                onSelected: (_) {
                  ref.read(adminLevelFilterProvider.notifier).state = filter;
                },
                labelStyle: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 12,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.surface,
                side: BorderSide(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.gold.withValues(alpha: 0.3),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getLabel(AdminLevelFilter filter) {
    switch (filter) {
      case AdminLevelFilter.all:
        return '全部';
      case AdminLevelFilter.zhou:
        return '州';
      case AdminLevelFilter.jun:
        return '郡';
      case AdminLevelFilter.xian:
        return '县';
    }
  }
}
