import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/classical_app_bar.dart';
import '../../../core/widgets/classical_card.dart';
import '../../../domain/enums/admin_level.dart';
import '../../../domain/entities/ancient_location.dart';
import '../../providers/database_provider.dart';
import '../../providers/current_dynasty_provider.dart';

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
  AdminLevel? _levelFilter;
  String _sortBy = 'relevance'; // relevance, name, level

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
    final dynastyId = ref.read(currentDynastyIdProvider);
    final dao = await db.ancientLocationDao;
    final allResults = await dao.searchByName(_query, dynastyId: dynastyId);

    if (mounted) {
      setState(() {
        _results = allResults;
        _isSearching = false;
      });
    }
  }

  List<AncientLocation> get _filteredResults {
    var results = _results;
    if (_levelFilter != null) {
      results = results.where((l) => l.adminLevel == _levelFilter).toList();
    }
    switch (_sortBy) {
      case 'name':
        results.sort((a, b) => a.name.compareTo(b.name));
      case 'level':
        const order = {AdminLevel.zhou: 0, AdminLevel.jun: 1, AdminLevel.xian: 2};
        results.sort((a, b) => order[a.adminLevel]!.compareTo(order[b.adminLevel]!));
      default:
        break; // relevance = default order from DB
    }
    return results;
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
    final filtered = _filteredResults;

    return Scaffold(
      appBar: const ClassicalAppBar(title: '搜索地名'),
      body: Column(
        children: [
          // Search field
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

          // Filter and sort row
          if (_results.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  // Level filter chips
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _FilterChip(
                            label: '全部',
                            selected: _levelFilter == null,
                            onTap: () => setState(() => _levelFilter = null),
                          ),
                          const SizedBox(width: 6),
                          _FilterChip(
                            label: '州',
                            selected: _levelFilter == AdminLevel.zhou,
                            onTap: () =>
                                setState(() => _levelFilter = AdminLevel.zhou),
                          ),
                          const SizedBox(width: 6),
                          _FilterChip(
                            label: '郡',
                            selected: _levelFilter == AdminLevel.jun,
                            onTap: () =>
                                setState(() => _levelFilter = AdminLevel.jun),
                          ),
                          const SizedBox(width: 6),
                          _FilterChip(
                            label: '县',
                            selected: _levelFilter == AdminLevel.xian,
                            onTap: () =>
                                setState(() => _levelFilter = AdminLevel.xian),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Sort button
                  PopupMenuButton<String>(
                    initialValue: _sortBy,
                    onSelected: (value) => setState(() => _sortBy = value),
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'relevance', child: Text('相关度')),
                      const PopupMenuItem(value: 'name', child: Text('名称')),
                      const PopupMenuItem(value: 'level', child: Text('行政级别')),
                    ],
                    child: const Icon(Icons.sort, color: AppColors.gold, size: 20),
                  ),
                ],
              ),
            ),

          // Results
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                : _query.isEmpty
                    ? _buildEmptyHint()
                    : filtered.isEmpty
                        ? const Center(child: Text('未找到相关地名'))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final loc = filtered[index];
                              return _ResultCard(
                                location: loc,
                                onTap: () {
                                  switch (loc.adminLevel) {
                                    case AdminLevel.zhou:
                                      context.go('/browse/jun?parentId=${loc.id}');
                                    case AdminLevel.jun:
                                      context.go('/browse/xian?parentId=${loc.id}');
                                    case AdminLevel.xian:
                                      context.go('/location/${loc.id}', extra: loc);
                                  }
                                },
                              );
                            },
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
          Icon(Icons.search, size: 64, color: AppColors.textHint.withValues(alpha: 0.5)),
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.textHint.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontFamily: AppTypography.fontFamily,
            color: selected ? AppColors.primary : AppColors.textHint,
          ),
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
                  color: AppColors.primary.withValues(alpha: 0.1),
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
