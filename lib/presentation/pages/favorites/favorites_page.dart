import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/classical_app_bar.dart';
import '../../../core/widgets/classical_card.dart';
import '../../../domain/entities/user_favorite.dart';
import '../../../domain/entities/dynasty.dart';
import '../../providers/favorites_providers.dart';
import '../../providers/current_dynasty_provider.dart';
import '../../providers/database_provider.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(allFavoritesProvider);
    final dynastiesAsync = ref.watch(allDynastiesProvider);

    return Scaffold(
      appBar: const ClassicalAppBar(title: '我的收藏'),
      body: favoritesAsync.when(
        data: (favorites) {
          if (favorites.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.favorite_border, size: 48, color: AppColors.textHint),
                  SizedBox(height: 12),
                  Text('暂无收藏', style: TextStyle(color: AppColors.textHint)),
                ],
              ),
            );
          }
          return dynastiesAsync.when(
            data: (dynasties) => _FavoritesList(
              favorites: favorites,
              dynasties: dynasties,
            ),
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            ),
            error: (_, _) => const Center(child: Text('加载失败')),
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

class _FavoritesList extends ConsumerWidget {
  final List<UserFavorite> favorites;
  final List<Dynasty> dynasties;

  const _FavoritesList({required this.favorites, required this.dynasties});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Group by dynasty
    final grouped = <int, List<UserFavorite>>{};
    for (final fav in favorites) {
      grouped.putIfAbsent(fav.dynastyId, () => []).add(fav);
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        for (final entry in grouped.entries) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              '${dynasties.firstWhere((d) => d.id == entry.key, orElse: () => dynasties.first).name}(${entry.value.length})',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          for (final fav in entry.value)
            _FavoriteItem(favorite: fav),
        ],
      ],
    );
  }
}

class _FavoriteItem extends ConsumerWidget {
  final UserFavorite favorite;
  const _FavoriteItem({required this.favorite});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ClassicalCard(
      onTap: () => context.go('/map'),
      child: FutureBuilder<String>(
        future: _getLocationName(ref),
        builder: (context, snapshot) => ListTile(
          dense: true,
          leading: const Icon(Icons.place, color: AppColors.gold),
          title: Text(
            snapshot.data ?? '地点 #${favorite.locationId}',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
        ),
      ),
    );
  }

  Future<String> _getLocationName(WidgetRef ref) async {
    final db = ref.read(databaseProvider);
    try {
      final dao = await db.ancientLocationDao;
      final loc = await dao.getById(favorite.locationId);
      return loc.name;
    } catch (_) {
      return '地点 #${favorite.locationId}';
    }
  }
}
