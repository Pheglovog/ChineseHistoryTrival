import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/classical_app_bar.dart';
import '../../../core/widgets/classical_card.dart';
import '../../../domain/entities/ancient_location.dart';
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
  List<AncientLocation> _junList = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final db = ref.read(databaseProvider);
      final dao = await db.ancientLocationDao;
      final zhou = await dao.getById(widget.parentLocationId);
      final children = await dao.getChildren(widget.parentLocationId);
      if (mounted) {
        setState(() {
          _zhouName = zhou.name;
          _junList = children;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ClassicalAppBar(title: _zhouName.isEmpty ? '郡列表' : _zhouName),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('加载失败: $_error'))
              : _junList.isEmpty
                  ? const Center(child: Text('暂无数据'))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _junList.length,
                      itemBuilder: (context, index) {
                        final jun = _junList[index];
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
                              if (jun.description != null &&
                                  jun.description!.isNotEmpty) ...[
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
                    ),
    );
  }
}
