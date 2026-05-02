import 'package:flutter/material.dart';
import '../../domain/entities/historical_figure.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../../domain/enums/figure_category.dart';

class FigureCard extends StatelessWidget {
  final HistoricalFigure figure;
  final VoidCallback? onTap;

  const FigureCard({super.key, required this.figure, this.onTap});

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
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Avatar placeholder
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _categoryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _categoryColor.withValues(alpha: 0.3),
                    width: 0.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    figure.name.substring(0, 1),
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: _categoryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          figure.name,
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (figure.alias != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            figure.alias!,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: _categoryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            figure.category.label,
                            style: TextStyle(
                              fontSize: 10,
                              color: _categoryColor,
                            ),
                          ),
                        ),
                        if (figure.title != null) ...[
                          const SizedBox(width: 6),
                          Text(
                            figure.title!,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textHint,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (figure.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        figure.description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.textHint, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Color get _categoryColor {
    switch (figure.category) {
      case FigureCategory.emperor:
        return AppColors.primary;
      case FigureCategory.minister:
        return AppColors.secondary;
      case FigureCategory.general:
        return AppColors.gold;
      case FigureCategory.scholar:
        return const Color(0xFF1565C0);
      case FigureCategory.other:
        return AppColors.textSecondary;
    }
  }
}
