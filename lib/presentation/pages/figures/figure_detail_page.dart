import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/classical_app_bar.dart';
import '../../../core/widgets/dynasty_badge.dart';
import '../../../domain/enums/figure_category.dart';
import '../../../domain/enums/relation_type.dart';
import '../../providers/figures_providers.dart';
import '../../providers/current_dynasty_provider.dart';

class FigureDetailPage extends ConsumerWidget {
  final int figureId;

  const FigureDetailPage({super.key, required this.figureId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final figureAsync = ref.watch(figureDetailProvider(figureId));
    final relationsAsync = ref.watch(figureRelationsProvider(figureId));
    final dynastyAsync = ref.watch(currentDynastyProvider);

    return Scaffold(
      appBar: const ClassicalAppBar(title: '人物详情'),
      body: figureAsync.when(
        data: (figure) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.gold, width: 0.5),
                      ),
                      child: Center(
                        child: Text(
                          figure.name.substring(0, 1),
                          style: AppTypography.headlineLarge.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      figure.name,
                      style: AppTypography.headlineLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (figure.alias != null)
                      Text(
                        figure.alias!,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    const SizedBox(height: 8),
                    dynastyAsync.when(
                      data: (d) => DynastyBadge(
                        dynastyName: d?.name ?? '',
                        period: d != null
                            ? _formatPeriod(d.startYear, d.endYear)
                            : null,
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, _) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Info section
              _InfoRow(
                  label: '头衔', value: figure.title ?? figure.category.label),
              if (figure.birthYear != null)
                _InfoRow(
                  label: '生卒年',
                  value:
                      '${_formatYear(figure.birthYear!)} - ${figure.deathYear != null ? _formatYear(figure.deathYear!) : '?'}',
                ),
              if (figure.description != null) ...[
                const SizedBox(height: 16),
                Text(
                  '简介',
                  style: AppTypography.headlineSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  figure.description!,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.8,
                  ),
                ),
              ],
              if (figure.biography != null) ...[
                const SizedBox(height: 16),
                Text(
                  '生平',
                  style: AppTypography.headlineSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  figure.biography!,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.8,
                  ),
                ),
              ],

              // Related locations
              const SizedBox(height: 24),
              Text(
                '关联地点',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              relationsAsync.when(
                data: (relations) {
                  if (relations.isEmpty) {
                    return const Text('暂无关联地点',
                        style: TextStyle(color: AppColors.textHint));
                  }
                  return Column(
                    children: [
                      for (final rel in relations)
                        Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(
                                color: AppColors.gold, width: 0.5),
                          ),
                          color: AppColors.surface,
                          child: ListTile(
                            dense: true,
                            title: Text(
                              '地点 #${rel.locationId}',
                              style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.textPrimary),
                            ),
                            subtitle: rel.description != null
                                ? Text(
                                    rel.description!,
                                    style: AppTypography.bodySmall,
                                  )
                                : Text(
                                    rel.relationType.label,
                                    style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.textHint),
                                  ),
                            trailing: const Icon(Icons.map_outlined,
                                size: 18, color: AppColors.gold),
                            onTap: () => context.go('/map'),
                          ),
                        ),
                    ],
                  );
                },
                loading: () => const Center(
                  child: SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                error: (_, _) => const Text('加载失败'),
              ),
            ],
          ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.gold),
        ),
        error: (e, _) => Center(child: Text('加载失败: $e')),
      ),
    );
  }

  String _formatYear(int year) => year < 0 ? '前${-year}年' : '$year年';
  String _formatPeriod(int start, int end) =>
      '${_formatYear(start)} - ${_formatYear(end)}';
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(label,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
