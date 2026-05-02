import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../providers/locations_provider.dart';

/// Panel showing how a location name changed across dynasties.
class HistoricalChangesPanel extends ConsumerWidget {
  final String locationName;

  const HistoricalChangesPanel({super.key, required this.locationName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final changesAsync = ref.watch(crossDynastyLocationsProvider(locationName));

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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              '历史变迁：$locationName',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: changesAsync.when(
              data: (changes) {
                if (changes.isEmpty) {
                  return const Center(
                    child: Text(
                      '暂无其他朝代的相关记录',
                      style: TextStyle(color: AppColors.textHint),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: changes.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final row = changes[index];
                    final dynastyName = row['dynasty_name'] as String? ?? '';
                    final startYear = row['start_year'] as int? ?? 0;
                    final endYear = row['end_year'] as int? ?? 0;
                    final name = row['name'] as String? ?? '';
                    final alias = row['alias'] as String?;
                    final adminLevel = row['admin_level'] as String? ?? '';
                    final levelLabels = {'zhou': '州', 'jun': '郡', 'xian': '县'};
                    final period = '${startYear < 0 ? '前${-startYear}' : startYear}-'
                        '${endYear < 0 ? '前${-endYear}' : endYear}';

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          // Timeline dot
                          Column(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: AppColors.gold,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              if (index < changes.length - 1)
                                Container(
                                  width: 2,
                                  height: 32,
                                  color: AppColors.gold.withValues(alpha: 0.3),
                                ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      dynastyName,
                                      style: AppTypography.bodyMedium.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      period,
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.textHint,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      name,
                                      style: AppTypography.bodyLarge.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (alias != null) ...[
                                      const SizedBox(width: 8),
                                      Text(
                                        '（$alias）',
                                        style: AppTypography.bodySmall.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                    if (levelLabels[adminLevel] != null) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary
                                              .withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          levelLabels[adminLevel]!,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.gold),
              ),
              error: (_, _) => const Center(
                child: Text('加载失败', style: TextStyle(color: AppColors.textHint)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
