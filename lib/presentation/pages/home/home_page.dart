import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/classical_app_bar.dart';
import '../../../core/widgets/classical_card.dart';
import '../../../core/widgets/dynasty_badge.dart';
import '../../providers/database_provider.dart';

/// 首页 - 功能入口 + 朝代标签 + 统计
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const ClassicalAppBar(
        title: '华夏足迹',
        showBackButton: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dynasty badge
            Center(
              child: DynastyBadge(
                dynastyName: '汉朝',
                period: '202BC-220AD',
              ),
            ),
            const SizedBox(height: 24),

            // Feature entry cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '功能入口',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            _FeatureCard(
              icon: Icons.map_outlined,
              title: '地图探索',
              subtitle: '在地图上探索汉代地名',
              onTap: () => context.go('/map'),
            ),
            _FeatureCard(
              icon: Icons.list_alt_outlined,
              title: '层级浏览',
              subtitle: '按州、郡、县逐级浏览',
              onTap: () => context.go('/browse'),
            ),
            _FeatureCard(
              icon: Icons.search,
              title: '搜索地名',
              subtitle: '搜索古代地名及现代对照',
              onTap: () => context.go('/search'),
            ),

            const SizedBox(height: 24),

            // Statistics row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '数据统计',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _StatisticsRow(),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClassicalCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.textHint),
        ],
      ),
    );
  }
}

class _StatisticsRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: '州',
            future: db.ancientLocationDao
                .getByDynastyAndLevel(1, 'zhou')
                .then((list) => list.length),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            label: '郡',
            future: db.ancientLocationDao
                .getByDynastyAndLevel(1, 'jun')
                .then((list) => list.length),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            label: '县',
            future: db.ancientLocationDao
                .getByDynastyAndLevel(1, 'xian')
                .then((list) => list.length),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final Future<int> future;

  const _StatCard({required this.label, required this.future});

  @override
  Widget build(BuildContext context) {
    return ClassicalCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: FutureBuilder<int>(
        future: future,
        builder: (context, snapshot) {
          return Column(
            children: [
              Text(
                '${snapshot.data ?? '-'}',
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
