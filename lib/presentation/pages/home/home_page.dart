import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/classical_app_bar.dart';
import '../../../core/widgets/classical_card.dart';
import '../../../core/widgets/dynasty_badge.dart';
import '../../../core/widgets/dynasty_selector_sheet.dart';
import '../../providers/database_provider.dart';
import '../../providers/current_dynasty_provider.dart';

/// 首页 - 功能入口 + 朝代标签 + 统计
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dynastyAsync = ref.watch(currentDynastyProvider);

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
            // Dynasty badge - clickable to switch
            Center(
              child: dynastyAsync.when(
                data: (dynasty) => DynastyBadge(
                  dynastyName: dynasty?.name ?? '选择朝代',
                  period: dynasty != null
                      ? _formatPeriod(dynasty.startYear, dynasty.endYear)
                      : null,
                  onTap: () => _showDynastySelector(context),
                ),
                loading: () => const DynastyBadge(dynastyName: '加载中...'),
                error: (_, _) => const DynastyBadge(dynastyName: '选择朝代'),
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
              subtitle: '在地图上探索古代地名',
              onTap: () => context.go('/map'),
            ),
            _FeatureCard(
              icon: Icons.list_alt_outlined,
              title: '层级浏览',
              subtitle: '按行政区划逐级浏览',
              onTap: () => context.go('/browse'),
            ),
            _FeatureCard(
              icon: Icons.search,
              title: '搜索地名',
              subtitle: '搜索古代地名及现代对照',
              onTap: () => context.go('/search'),
            ),
            _FeatureCard(
              icon: Icons.person_outline,
              title: '历史名人',
              subtitle: '了解与各地相关的历史人物',
              onTap: () => context.go('/figures'),
            ),
            _FeatureCard(
              icon: Icons.route_outlined,
              title: '古人足迹',
              subtitle: '跟随历史人物的旅行路线',
              onTap: () => context.go('/routes'),
            ),
            _FeatureCard(
              icon: Icons.auto_stories_outlined,
              title: '每日一史',
              subtitle: '每天一条历史小知识',
              onTap: () => context.go('/daily-history'),
            ),

            const SizedBox(height: 16),

            // Quick actions: favorites & history
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.favorite_outline,
                      label: '我的收藏',
                      onTap: () => context.go('/favorites'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.history,
                      label: '浏览历史',
                      onTap: () => context.go('/history'),
                    ),
                  ),
                ],
              ),
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

  void _showDynastySelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const DynastySelectorSheet(),
    );
  }

  String _formatPeriod(int start, int end) {
    final startStr = start < 0 ? '${-start}BC' : '$start';
    final endStr = end < 0 ? '${-end}BC' : '${end}AD';
    return '$startStr-$endStr';
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
              color: AppColors.primary.withValues(alpha: 0.1),
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

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClassicalCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        children: [
          Icon(icon, color: AppColors.gold, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatisticsRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    final dynastyId = ref.watch(currentDynastyIdProvider);

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: '州',
            future: db.ancientLocationDao.then((dao) =>
                dao.getByDynastyAndLevel(dynastyId, 'zhou').then((l) => l.length)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            label: '郡',
            future: db.ancientLocationDao.then((dao) =>
                dao.getByDynastyAndLevel(dynastyId, 'jun').then((l) => l.length)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            label: '县',
            future: db.ancientLocationDao.then((dao) =>
                dao.getByDynastyAndLevel(dynastyId, 'xian').then((l) => l.length)),
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
