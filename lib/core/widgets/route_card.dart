import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../../domain/enums/route_difficulty.dart';

class RouteCardWidget extends StatelessWidget {
  final String name;
  final String? figureName;
  final RouteDifficulty difficulty;
  final int estimatedDays;
  final String? startName;
  final String? endName;
  final VoidCallback? onTap;

  const RouteCardWidget({
    super.key,
    required this.name,
    this.figureName,
    this.difficulty = RouteDifficulty.medium,
    this.estimatedDays = 1,
    this.startName,
    this.endName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.gold, width: 0.5),
      ),
      elevation: 2,
      color: AppColors.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _DifficultyTag(difficulty: difficulty),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (figureName != null) ...[
                    Icon(Icons.person_outline, size: 14,
                        color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      figureName!,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Icon(Icons.schedule, size: 14,
                      color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '$estimatedDays天',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              if (startName != null && endName != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    _RoutePoint(name: startName!),
                    Expanded(
                      child: Container(
                        height: 1,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.gold, AppColors.goldLight],
                          ),
                        ),
                      ),
                    ),
                    _RoutePoint(name: endName!),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DifficultyTag extends StatelessWidget {
  final RouteDifficulty difficulty;
  const _DifficultyTag({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    final color = switch (difficulty) {
      RouteDifficulty.easy => AppColors.success,
      RouteDifficulty.medium => AppColors.gold,
      RouteDifficulty.hard => AppColors.primary,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        difficulty.label,
        style: TextStyle(
          fontSize: 10,
          fontFamily: AppTypography.fontFamily,
          color: color,
        ),
      ),
    );
  }
}

class _RoutePoint extends StatelessWidget {
  final String name;
  const _RoutePoint({required this.name});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: AppColors.gold,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          name,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
