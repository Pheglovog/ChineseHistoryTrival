import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/classical_app_bar.dart';
import '../../../core/widgets/classical_card.dart';
import '../../../domain/entities/browse_history.dart';
import '../../providers/favorites_providers.dart';
import '../../providers/database_provider.dart';

class BrowseHistoryPage extends ConsumerWidget {
  const BrowseHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(browseHistoryProvider);

    return Scaffold(
      appBar: const ClassicalAppBar(title: '浏览历史'),
      body: historyAsync.when(
        data: (history) {
          if (history.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history, size: 48, color: AppColors.textHint),
                  SizedBox(height: 12),
                  Text('暂无浏览记录',
                      style: TextStyle(color: AppColors.textHint)),
                ],
              ),
            );
          }
          return Column(
            children: [
              // Clear button
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _showClearDialog(context, ref),
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('清除全部'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final item = history[index];
                    return _HistoryItem(historyItem: item);
                  },
                ),
              ),
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

  void _showClearDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('清除浏览历史'),
        content: const Text('确定要清除所有浏览记录吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final db = ref.read(databaseProvider);
              final dao = await db.browseHistoryDao;
              await dao.clearAll();
              ref.invalidate(browseHistoryProvider);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('确定',
                style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}

class _HistoryItem extends ConsumerWidget {
  final BrowseHistory historyItem;
  const _HistoryItem({required this.historyItem});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ClassicalCard(
      onTap: () => context.go('/map'),
      child: FutureBuilder<String>(
        future: _getLocationName(ref),
        builder: (context, snapshot) => ListTile(
          dense: true,
          leading: const Icon(Icons.history, color: AppColors.textHint),
          title: Text(
            snapshot.data ?? '地点 #${historyItem.locationId}',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Text(
            _formatTime(historyItem.visitedAt),
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textHint,
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
      final loc = await dao.getById(historyItem.locationId);
      return loc.name;
    } catch (_) {
      return '地点 #${historyItem.locationId}';
    }
  }

  String _formatTime(DateTime time) {
    return '${time.month}月${time.day}日 ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}
