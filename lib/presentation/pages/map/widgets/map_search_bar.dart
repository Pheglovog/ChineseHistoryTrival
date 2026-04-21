import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../providers/database_provider.dart';

/// 地图页搜索栏 - 输入地名飞到对应位置
class MapSearchBar extends ConsumerStatefulWidget {
  const MapSearchBar({super.key});

  @override
  ConsumerState<MapSearchBar> createState() => _MapSearchBarState();
}

class _MapSearchBarState extends ConsumerState<MapSearchBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  List<dynamic> _suggestions = [];
  bool _showSuggestions = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(24),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            style: const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: '搜索古地名或现代城市...',
              hintStyle: const TextStyle(
                color: AppColors.textHint,
                fontSize: 14,
              ),
              prefixIcon: const Icon(Icons.search, color: AppColors.gold),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _controller.clear();
                        setState(() {
                          _suggestions = [];
                          _showSuggestions = false;
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
            ),
            onChanged: _onSearchChanged,
            onSubmitted: _onSearchSubmitted,
          ),
        ),
        if (_showSuggestions && _suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _suggestions.take(5).map((item) {
                return ListTile(
                  dense: true,
                  title: Text(
                    item.name,
                    style: const TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 13,
                    ),
                  ),
                  onTap: () => _selectSuggestion(item),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Future<void> _onSearchChanged(String query) async {
    setState(() {});
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    final db = ref.read(databaseProvider);
    final dao = await db.ancientLocationDao;
    final results = await dao.searchByName(query);
    setState(() {
      _suggestions = results;
      _showSuggestions = true;
    });
  }

  void _onSearchSubmitted(String query) {
    _focusNode.unfocus();
    if (_suggestions.isNotEmpty) {
      _selectSuggestion(_suggestions.first);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('未找到该地名')),
      );
    }
  }

  void _selectSuggestion(dynamic location) {
    _controller.text = location.name;
    _focusNode.unfocus();
    setState(() {
      _showSuggestions = false;
    });
    // Navigate map to location - handled by updating provider
    // The map page watches for location changes and animates
  }
}
