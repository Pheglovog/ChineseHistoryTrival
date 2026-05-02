import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/classical_app_bar.dart';

import '../../../../core/widgets/dynasty_badge.dart';
import '../../../../core/widgets/favorite_button.dart';
import '../../../../core/widgets/history_timeline.dart';
import '../../../../domain/entities/ancient_location.dart';
import '../../../providers/figures_providers.dart';
import '../../../providers/favorites_providers.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/current_dynasty_provider.dart';

class LocationDetailPage extends ConsumerStatefulWidget {
  final AncientLocation location;

  const LocationDetailPage({super.key, required this.location});

  @override
  ConsumerState<LocationDetailPage> createState() => _LocationDetailPageState();
}

class _LocationDetailPageState extends ConsumerState<LocationDetailPage> {
  @override
  void initState() {
    super.initState();
    _recordBrowseHistory();
  }

  void _recordBrowseHistory() {
    Future.microtask(() async {
      final db = ref.read(databaseProvider);
      final dao = await db.browseHistoryDao;
      await dao.upsert(widget.location.id, widget.location.dynastyId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final location = widget.location;
    final figuresAsync = ref.watch(figuresByLocationProvider(location.id));
    final isFav = ref.watch(isFavoriteProvider(location.id)).valueOrNull ?? false;
    final dynastyAsync = ref.watch(currentDynastyProvider);

    return Scaffold(
      appBar: const ClassicalAppBar(title: '地点详情'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location.name,
                        style: AppTypography.headlineLarge.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (location.alias != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '别名：${location.alias!}',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                FavoriteButton(
                  isFavorite: isFav,
                  onTap: () => _toggleFavorite(isFav),
                ),
              ],
            ),
            const SizedBox(height: 12),
            dynastyAsync.when(
              data: (d) => DynastyBadge(
                dynastyName: d?.name ?? '',
                period: d != null
                    ? '${d.startYear < 0 ? '前${-d.startYear}' : d.startYear}-${d.endYear < 0 ? '前${-d.endYear}' : d.endYear}AD'
                    : null,
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),

            // Info section
            Text(
              '基本信息',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            if (location.description != null)
              _InfoRow(label: '简介', value: location.description!),
            if (location.historicalSignificance != null)
              _InfoRow(label: '历史意义', value: location.historicalSignificance!),
            if (location.yearEstablished != null)
              _InfoRow(
                label: '设立年份',
                value: location.yearEstablished! < 0
                    ? '前${-location.yearEstablished!}年'
                    : '${location.yearEstablished}年',
              ),

            const SizedBox(height: 24),

            // Related figures
            Text(
              '历史人物',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            figuresAsync.when(
              data: (figures) {
                if (figures.isEmpty) {
                  return const Text('暂无关联人物',
                      style: TextStyle(color: AppColors.textHint));
                }
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final fig in figures)
                      ActionChip(
                        label: Text(fig.name),
                        avatar: CircleAvatar(
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          child: Text(fig.name.substring(0, 1),
                              style: const TextStyle(fontSize: 12)),
                        ),
                        onPressed: () => context.go('/figures/${fig.id}'),
                      ),
                  ],
                );
              },
              loading: () => const Center(
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (_, _) => const Text('加载失败'),
            ),

            const SizedBox(height: 24),

            // Timeline (placeholder with historical significance as event)
            if (location.historicalSignificance != null) ...[
              Text(
                '历史时间线',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              HistoryTimeline(
                events: [
                  if (location.yearEstablished != null)
                    TimelineEvent(
                      year: location.yearEstablished! < 0
                          ? '前${-location.yearEstablished!}年'
                          : '${location.yearEstablished}年',
                      title: '${location.name}设立',
                      description: location.description,
                    ),
                  TimelineEvent(
                    title: location.historicalSignificance!,
                  ),
                ],
              ),
            ],

            const SizedBox(height: 24),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.go('/map'),
                    icon: const Icon(Icons.map_outlined, size: 18),
                    label: const Text('查看地图'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.gold,
                      side: const BorderSide(color: AppColors.gold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _shareLocation(),
                    icon: const Icon(Icons.share_outlined, size: 18),
                    label: const Text('分享'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleFavorite(bool isFav) async {
    final loc = widget.location;
    final db = ref.read(databaseProvider);
    if (isFav) {
      final dao = await db.userFavoriteDao;
      await dao.removeFavorite(loc.id);
    } else {
      final dao = await db.userFavoriteDao;
      await dao.addFavorite(loc.id, loc.dynastyId);
    }
    ref.invalidate(isFavoriteProvider(loc.id));
    ref.invalidate(favoritesProvider);
    ref.invalidate(allFavoritesProvider);
  }

  void _shareLocation() {
    final loc = widget.location;
    final text = '${loc.name}'
        '${loc.alias != null ? '（${loc.alias}）' : ''}'
        '\n华夏足迹 - 跟随古人脚步旅游';
    Share.share(text);
  }
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
