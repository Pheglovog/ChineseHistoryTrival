import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/classical_app_bar.dart';
import '../../../core/widgets/classical_card.dart';
import '../../../domain/entities/ancient_location.dart';
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
  List<AncientLocation> _xianList = [];
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
      final jun = await dao.getById(widget.parentLocationId);
      final children = await dao.getChildren(widget.parentLocationId);
      if (mounted) {
        setState(() {
          _junName = jun.name;
          _xianList = children;
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
      appBar: ClassicalAppBar(title: _junName.isEmpty ? '县列表' : _junName),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('加载失败: $_error'))
              : _xianList.isEmpty
                  ? const Center(child: Text('暂无数据'))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _xianList.length,
                      itemBuilder: (context, index) {
                        final xian = _xianList[index];
                        return ClassicalCard(
                          onTap: () =>
                              context.go('/map?locationId=${xian.id}'),
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
                    ),
    );
  }
}
