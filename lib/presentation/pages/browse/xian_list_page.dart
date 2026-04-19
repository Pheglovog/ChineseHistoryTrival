import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/classical_app_bar.dart';
import '../../../core/widgets/classical_card.dart';
import '../../providers/database_provider.dart';

/// 县列表页 - 展示所选郡下属的县
class XianListPage extends ConsumerStatefulWidget {
  final int parentLocationId;

  const XianListPage({super.key, required this.parentLocationId});

  @override
  ConsumerState<XianListPage> createState() => _XianListPageState();
}

class _XianListPageState extends ConsumerState<XianListPage> {
  String _junName = '';

  @override
  void initState() {
    super.initState();
    _loadJunName();
  }

  Future<void> _loadJunName() async {
    final db = ref.read(databaseProvider);
    final jun = await db.ancientLocationDao.getById(widget.parentLocationId);
    if (mounted) {
      setState(() => _junName = jun.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);

    return Scaffold(
      appBar: ClassicalAppBar(title: _junName.isEmpty ? '县列表' : _junName),
      body: StreamBuilder<List<AncientLocation>>(
        stream: db.ancientLocationDao.watchChildren(widget.parentLocationId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('加载失败: ${snapshot.error}'));
          }
          final xianList = snapshot.data ?? [];
          if (xianList.isEmpty) {
            return const Center(child: Text('暂无数据'));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: xianList.length,
            itemBuilder: (context, index) {
              final xian = xianList[index];
              return ClassicalCard(
                onTap: () => context.go('/map?locationId=${xian.id}'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      xian.name,
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (xian.historicalSignificance != null &&
                        xian.historicalSignificance!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        xian.historicalSignificance!,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
