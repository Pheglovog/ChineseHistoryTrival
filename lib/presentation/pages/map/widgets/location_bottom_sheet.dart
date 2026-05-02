import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/favorite_button.dart';
import '../../../../domain/entities/ancient_location.dart';
import '../../../providers/figures_providers.dart';
import '../../../providers/favorites_providers.dart';
import '../../../providers/database_provider.dart';
import 'historical_changes_panel.dart';

/// 标记点击底部弹窗 - 显示地点详情
class LocationBottomSheet extends ConsumerStatefulWidget {
  final AncientLocation location;

  const LocationBottomSheet({
    super.key,
    required this.location,
  });

  @override
  ConsumerState<LocationBottomSheet> createState() => _LocationBottomSheetState();
}

class _LocationBottomSheetState extends ConsumerState<LocationBottomSheet> {
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

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
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

          // Header row: name + favorite button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location.name,
                        style: AppTypography.headlineMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildLevelBadge(location.adminLevel.toString()),
                    ],
                  ),
                ),
                FavoriteButton(
                  isFavorite: isFav,
                  onTap: () => _toggleFavorite(isFav),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Details
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildDetails(location),
          ),

          // Related figures
          figuresAsync.when(
            data: (figures) {
              if (figures.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      '历史人物',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 80,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: figures.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final fig = figures[index];
                        return Container(
                          width: 120,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.gold.withValues(alpha: 0.3),
                              width: 0.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                fig.name,
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (fig.title != null)
                                Text(
                                  fig.title!,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textHint,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),

          const SizedBox(height: 24),

          // Historical changes button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => HistoricalChangesPanel(
                      locationName: location.name,
                    ),
                  );
                },
                icon: const Icon(Icons.history_edu_outlined, size: 18),
                label: const Text('历史变迁'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.gold,
                  side: const BorderSide(color: AppColors.gold),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
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

  Widget _buildLevelBadge(String level) {
    final labels = {'zhou': '州', 'jun': '郡', 'xian': '县'};
    final label = labels[level] ?? level;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary, width: 0.5),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 12,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildDetails(AncientLocation loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (loc.description != null)
          _buildDetailRow('简介', loc.description),
        if (loc.historicalSignificance != null)
          _buildDetailRow('历史意义', loc.historicalSignificance),
        if (loc.alias != null) _buildDetailRow('别名', loc.alias),
      ],
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    if (value == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
