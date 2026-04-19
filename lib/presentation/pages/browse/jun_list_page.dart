import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/classical_app_bar.dart';
import '../../../core/widgets/classical_card.dart';
import '../../providers/database_provider.dart';

/// 郡列表页 - 展示所选州下属的郡
class JunListPage extends ConsumerStatefulWidget {
  final int parentLocationId;

  const JunListPage({super.key, required this.parentLocationId});

  @override
  ConsumerState<JunListPage> createState() => _JunListPageState();
}

class _JunListPageState extends ConsumerState<JunListPage> {
  String _zhouName = '';

  @override
  void initState() {
    super.initState();
    _loadZhouName();
  }

  Future<void> _loadZhouName() async {
    final db = ref.read(databaseProvider);
    final zhou = await db.ancientLocationDao.getById(widget.parentLocationId);
    if (mounted) {
      setState(() => _zhouName = zhou.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);
    final junAsync = StreamBuilder<List<AncientLocation>>(
      stream: db.ancientLocationDao.watchChildren(widget.parentLocationId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('加载失败: ${snapshot.error}'));
        }
        final junList = snapshot.data ?? [];
        if (junList.isEmpty) {
          return const Center(child: Text('暂无数据'));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: junList.length,
          itemBuilder: (context, index) {
            final jun = junList[index];
            return ClassicalCard(
              onTap: () => context.go(
                '/browse/xian?parentId=${jun.id}',
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    jun.name,
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (jun.description != null && jun.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      jun.description!,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );

    return Scaffold(
      appBar: ClassicalAppBar(title: _zhouName.isEmpty ? '郡列表' : _zhouName),
      body: junAsync,
    );
  }
}
