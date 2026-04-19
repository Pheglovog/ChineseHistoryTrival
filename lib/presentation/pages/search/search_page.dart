import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/classical_app_bar.dart';
import '../../../core/widgets/classical_card.dart';
import '../../../domain/enums/admin_level.dart';
import '../../providers/database_provider.dart';

/// 搜索页 - 古代地名搜索，300ms 防抖
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _query = '';
  List<AncientLocation> _results = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      final query = _searchController.text.trim();
      if (query != _query) {
        _query = query;
        _performSearch();
      }
    });
  }

  Future<void> _performSearch() async {
    if (_query.isEmpty) {
      setState(() {
        _results = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    final db = ref.read(databaseProvider);
    // Search across all admin levels for dynasty 1 (Han)
    final zhouResults =
        await db.ancientLocationDao.getByDynastyAndLevel(1, 'zhou');
    final junResults =
        await db.ancientLocationDao.getByDynastyAndLevel(1, 'jun');
    final xianResults =
        await db.ancientLocationDao.getByDynastyAndLevel(1, 'xian');

    final allResults = <AncientLocation>[
      ...zhouResults,
      ...junResults,
      ...xianResults,
    ];

    final filtered = allResults
        .where((loc) => loc.name.contains(_query))
        .toList();

    if (mounted) {
      setState(() {
        _results = filtered;
        _isSearching = false;
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Group results by admin level
    final zhouResults =
        _results.where((l) => l.adminLevel == AdminLevel.zhou).toList();
    final junResults =
        _results.where((l) => l.adminLevel == AdminLevel.jun).toList();
    final xianResults =
        _results.where((l) => l.adminLevel == AdminLevel.xian).toList();

    return Scaffold(
      appBar: const ClassicalAppBar(title: '搜索地名'),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: '输入地名进行搜索...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.textHint),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _query = '';
                            _results = [];
                          });
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Results
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _query.isEmpty
                    ? _buildEmptyHint()
                    : _results.isEmpty
                        ? const Center(child: Text('未找到相关地名'))
                        : ListView(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            children: [
                              if (zhouResults.isNotEmpty) ...[
                                _SectionHeader(label: '州'),
                                ...zhouResults.map((l) => _ResultCard(
                                      location: l,
                                      onTap: () => context
                                          .go('/browse/jun?parentId=${l.id}'),
                                    )),
                              ],
                              if (junResults.isNotEmpty) ...[
                                _SectionHeader(label: '郡'),
                                ...junResults.map((l) => _ResultCard(
                                      location: l,
                                      onTap: () => context.go(
                                          '/browse/xian?parentId=${l.id}'),
                                    )),
                              ],
                              if (xianResults.isNotEmpty) ...[
                                _SectionHeader(label: '县'),
                                ...xianResults.map((l) => _ResultCard(
                                      location: l,
                                      onTap: () => context
                                          .go('/map?locationId=${l.id}'),
                                    )),
                              ],
                            ],
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHint() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search, size: 64, color: AppColors.textHint.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            '输入关键词搜索古代地名',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;

  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        label,
        style: AppTypography.labelLarge.copyWith(
          color: AppColors.gold,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final AncientLocation location;
  final VoidCallback onTap;

  const _ResultCard({required this.location, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClassicalCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                location.name,
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  location.adminLevel.label,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          if (location.description != null &&
              location.description!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              location.description!,
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
  }
}
