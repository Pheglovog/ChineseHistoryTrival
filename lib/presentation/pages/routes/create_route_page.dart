import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/database/app_database.dart';
import '../../../data/local/database/schema.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/classical_app_bar.dart';
import '../../../domain/entities/ancient_location.dart';
import '../../../domain/enums/admin_level.dart';
import '../../../domain/enums/route_difficulty.dart';
import '../../providers/database_provider.dart';
import '../../providers/current_dynasty_provider.dart';
import '../../providers/routes_providers.dart';

class CreateRoutePage extends ConsumerStatefulWidget {
  const CreateRoutePage({super.key});

  @override
  ConsumerState<CreateRoutePage> createState() => _CreateRoutePageState();
}

class _CreateRoutePageState extends ConsumerState<CreateRoutePage> {
  final _nameController = TextEditingController();
  final _searchController = TextEditingController();
  final List<AncientLocation> _selectedLocations = [];
  RouteDifficulty _difficulty = RouteDifficulty.medium;
  List<AncientLocation> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ClassicalAppBar(title: '创建自定义路线'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Route name
            Text(
              '路线名称',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: '输入路线名称...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Difficulty selector
            Text(
              '难度',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: RouteDifficulty.values.map((d) {
                final selected = d == _difficulty;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(d.label),
                    selected: selected,
                    onSelected: (_) => setState(() => _difficulty = d),
                    selectedColor: AppColors.primary.withValues(alpha: 0.1),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Search locations
            Text(
              '添加地点',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索地名...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.textHint),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchResults = [];
                            _isSearching = false;
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onSubmitted: _performSearch,
            ),
            const SizedBox(height: 8),

            // Search results
            if (_searchResults.isNotEmpty)
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final loc = _searchResults[index];
                    final alreadyAdded = _selectedLocations.any((l) => l.id == loc.id);
                    return ListTile(
                      dense: true,
                      title: Text(loc.name),
                      subtitle: Text(loc.adminLevel.label),
                      trailing: alreadyAdded
                          ? const Icon(Icons.check, color: AppColors.primary)
                          : const Icon(Icons.add, color: AppColors.gold),
                      onTap: alreadyAdded ? null : () => _addLocation(loc),
                    );
                  },
                ),
              ),
            if (_isSearching)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(color: AppColors.gold),
                ),
              ),
            const SizedBox(height: 20),

            // Selected locations (reorderable)
            Text(
              '已选地点（${_selectedLocations.length}）',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            if (_selectedLocations.isEmpty)
              const Text(
                '请搜索并添加地点',
                style: TextStyle(color: AppColors.textHint),
              )
            else
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _selectedLocations.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex--;
                    final item = _selectedLocations.removeAt(oldIndex);
                    _selectedLocations.insert(newIndex, item);
                  });
                },
                itemBuilder: (context, index) {
                  final loc = _selectedLocations[index];
                  return ListTile(
                    key: ValueKey(loc.id),
                    dense: true,
                    leading: CircleAvatar(
                      backgroundColor: AppColors.gold,
                      radius: 14,
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.white),
                      ),
                    ),
                    title: Text(loc.name),
                    subtitle: Text(loc.adminLevel.label),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => setState(() => _selectedLocations.removeAt(index)),
                    ),
                  );
                },
              ),
            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedLocations.length >= 2 ? _saveRoute : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('保存路线'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;
    setState(() => _isSearching = true);
    final db = ref.read(databaseProvider);
    final dynastyId = ref.read(currentDynastyIdProvider);
    final dao = await db.ancientLocationDao;
    final results = await dao.searchByName(query.trim(), dynastyId: dynastyId);
    if (mounted) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    }
  }

  void _addLocation(AncientLocation loc) {
    setState(() {
      _selectedLocations.add(loc);
    });
  }

  Future<void> _saveRoute() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入路线名称')),
      );
      return;
    }

    final db = await AppDatabase.database;
    final dynastyId = ref.read(currentDynastyIdProvider);

    final routeId = await db.insert(Schema.travelRoutes, {
      'dynasty_id': dynastyId,
      'name': name,
      'difficulty': _difficulty.name,
      'estimated_days': _selectedLocations.length,
      'is_custom': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    final batch = db.batch();
    for (int i = 0; i < _selectedLocations.length; i++) {
      batch.insert(Schema.routeStops, {
        'route_id': routeId,
        'order_index': i,
        'location_id': _selectedLocations[i].id,
        'title': _selectedLocations[i].name,
      });
    }
    await batch.commit(noResult: true);

    if (mounted) {
      ref.invalidate(routesByDynastyProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('路线已保存')),
      );
      Navigator.of(context).pop();
    }
  }
}
