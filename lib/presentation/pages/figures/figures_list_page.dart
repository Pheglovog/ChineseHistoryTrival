import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/classical_app_bar.dart';
import '../../../core/widgets/figure_card.dart';
import '../../../domain/entities/historical_figure.dart';
import '../../../domain/enums/figure_category.dart';
import '../../providers/figures_providers.dart';

class FiguresListPage extends ConsumerWidget {
  const FiguresListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final figuresAsync = ref.watch(figuresByDynastyProvider);

    return Scaffold(
      appBar: const ClassicalAppBar(title: '历史名人'),
      body: figuresAsync.when(
        data: (figures) {
          if (figures.isEmpty) {
            return const Center(child: Text('暂无人物数据'));
          }

          // Group by category
          final grouped = <FigureCategory, List<HistoricalFigure>>{};
          for (final fig in figures) {
            grouped.putIfAbsent(fig.category, () => []).add(fig);
          }

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              for (final entry in grouped.entries) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Text(
                    entry.key.label,
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                for (final fig in entry.value)
                  FigureCard(
                    figure: fig,
                    onTap: () => context.go('/figures/${fig.id}'),
                  ),
              ],
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.gold),
        ),
        error: (e, _) => Center(child: Text('加载失败: $e')),
      ),
    );
  }
}
