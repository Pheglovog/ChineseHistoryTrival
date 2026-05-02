import 'package:flutter/material.dart';
import '../../domain/entities/history_card.dart';
import '../../domain/enums/history_card_category.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class HistoryCardWidget extends StatelessWidget {
  final HistoryCard card;
  final VoidCallback? onTap;

  const HistoryCardWidget({super.key, required this.card, this.onTap});

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
                  _CategoryTag(category: card.category),
                  if (card.dateHint != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      card.dateHint!,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Text(
                card.title,
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                card.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryTag extends StatelessWidget {
  final HistoryCardCategory category;
  const _CategoryTag({required this.category});

  @override
  Widget build(BuildContext context) {
    final color = switch (category) {
      HistoryCardCategory.event => AppColors.primary,
      HistoryCardCategory.figure => AppColors.secondary,
      HistoryCardCategory.culture => const Color(0xFF6A1B9A),
      HistoryCardCategory.geography => const Color(0xFF0277BD),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        category.label,
        style: TextStyle(
          fontSize: 10,
          fontFamily: AppTypography.fontFamily,
          color: color,
        ),
      ),
    );
  }
}
