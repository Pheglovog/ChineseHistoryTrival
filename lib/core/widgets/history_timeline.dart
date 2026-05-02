import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class TimelineEvent {
  final String? year;
  final String title;
  final String? description;

  const TimelineEvent({this.year, required this.title, this.description});
}

class HistoryTimeline extends StatelessWidget {
  final List<TimelineEvent> events;
  const HistoryTimeline({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < events.length; i++)
          _TimelineNode(
            event: events[i],
            isLast: i == events.length - 1,
          ),
      ],
    );
  }
}

class _TimelineNode extends StatelessWidget {
  final TimelineEvent event;
  final bool isLast;

  const _TimelineNode({required this.event, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline axis
          SizedBox(
            width: 60,
            child: Column(
              children: [
                if (event.year != null)
                  Text(
                    event.year!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.gold,
                    ),
                  ),
                const SizedBox(height: 4),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.goldLight,
                      width: 1.5,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      color: AppColors.gold.withValues(alpha: 0.3),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Event card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.2),
                  width: 0.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (event.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      event.description!,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
