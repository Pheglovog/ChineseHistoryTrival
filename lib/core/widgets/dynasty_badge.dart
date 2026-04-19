import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// 朝代标签组件
class DynastyBadge extends StatelessWidget {
  final String dynastyName;
  final String? period;
  final VoidCallback? onTap;

  const DynastyBadge({
    super.key,
    required this.dynastyName,
    this.period,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryDark, AppColors.primary],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gold, width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              dynastyName,
              style: const TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            if (period != null) ...[
              const SizedBox(width: 4),
              Text(
                period!,
                style: const TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 10,
                  color: AppColors.goldLight,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
