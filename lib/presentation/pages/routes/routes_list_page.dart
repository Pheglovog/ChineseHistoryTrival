import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/classical_app_bar.dart';
import '../../../core/widgets/route_card.dart';
import '../../providers/routes_providers.dart';

class RoutesListPage extends ConsumerWidget {
  const RoutesListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routesAsync = ref.watch(routesByDynastyProvider);

    return Scaffold(
      appBar: const ClassicalAppBar(title: '古人足迹'),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/routes/create'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: routesAsync.when(
        data: (routes) {
          if (routes.isEmpty) {
            return const Center(child: Text('暂无路线数据'));
          }
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              for (final route in routes)
                RouteCardWidget(
                  name: route.name,
                  estimatedDays: route.estimatedDays,
                  difficulty: route.difficulty,
                  onTap: () => context.go('/routes/${route.id}'),
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
}
