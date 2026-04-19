import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/classical_app_bar.dart';
import '../../../core/widgets/classical_card.dart';
import '../../providers/location_provider.dart';

/// 汉代十三州 - 网格卡片展示
class ZhouListPage extends ConsumerWidget {
  const ZhouListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zhouAsync = ref.watch(zhouListProvider);

    return Scaffold(
      appBar: const ClassicalAppBar(title: '汉代十三州'),
      body: zhouAsync.when(
        data: (zhouList) {
          if (zhouList.isEmpty) {
            return const Center(child: Text('暂无数据'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: zhouList.length,
            itemBuilder: (context, index) {
              final zhou = zhouList[index];
              return ClassicalCard(
                onTap: () => context.go('/browse/jun?parentId=${zhou.id}'),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      zhou.name,
                      style: AppTypography.headlineSmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      zhou.description ?? '',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('加载失败: $error')),
      ),
    );
  }
}
