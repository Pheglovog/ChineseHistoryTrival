import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/dynasty.dart';
import '../../presentation/providers/current_dynasty_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class DynastySelectorSheet extends ConsumerWidget {
  const DynastySelectorSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dynastiesAsync = ref.watch(allDynastiesProvider);
    final currentId = ref.watch(currentDynastyIdProvider);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              '选择朝代',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          dynastiesAsync.when(
            data: (dynasties) => Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: dynasties.length,
                itemBuilder: (context, index) {
                  final dynasty = dynasties[index];
                  final isSelected = dynasty.id == currentId;
                  return _DynastyCard(
                    dynasty: dynasty,
                    isSelected: isSelected,
                    onTap: () {
                      ref.read(currentDynastyIdProvider.notifier).state =
                          dynasty.id;
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            ),
            error: (_, _) => const Center(child: Text('加载失败')),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _DynastyCard extends StatelessWidget {
  final Dynasty dynasty;
  final bool isSelected;
  final VoidCallback onTap;

  const _DynastyCard({
    required this.dynasty,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppColors.gold : AppColors.gold.withValues(alpha: 0.3),
          width: isSelected ? 1.5 : 0.5,
        ),
      ),
      elevation: isSelected ? 4 : 1,
      color: isSelected
          ? AppColors.gold.withValues(alpha: 0.05)
          : AppColors.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dynasty.name,
                      style: AppTypography.bodyLarge.copyWith(
                        color: isSelected ? AppColors.goldDark : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatPeriod(dynasty.startYear, dynasty.endYear),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (dynasty.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        dynasty.description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle, color: AppColors.gold, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPeriod(int start, int end) {
    final startStr = start < 0 ? '前${-start}年' : '$start年';
    final endStr = end < 0 ? '前${-end}年' : '$end年';
    return '$startStr - $endStr';
  }
}
