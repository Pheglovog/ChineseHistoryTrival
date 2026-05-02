import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/notification_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/classical_app_bar.dart';
import '../../../core/widgets/history_card_widget.dart';
import '../../../domain/enums/history_card_category.dart';
import '../../providers/history_cards_providers.dart';

class DailyHistoryPage extends ConsumerStatefulWidget {
  const DailyHistoryPage({super.key});

  @override
  ConsumerState<DailyHistoryPage> createState() => _DailyHistoryPageState();
}

class _DailyHistoryPageState extends ConsumerState<DailyHistoryPage> {
  bool _notificationEnabled = false;

  @override
  Widget build(BuildContext context) {
    final todayCard = ref.watch(todayCardProvider).valueOrNull;
    final cardsAsync = ref.watch(historyCardsProvider);

    return Scaffold(
      appBar: ClassicalAppBar(
        title: '每日一史',
        actions: [
          IconButton(
            icon: Icon(
              _notificationEnabled
                  ? Icons.notifications_active
                  : Icons.notifications_outlined,
              color: AppColors.gold,
              size: 22,
            ),
            onPressed: () => _toggleNotification(todayCard),
          ),
        ],
      ),
      body: cardsAsync.when(
        data: (cards) {
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              // Today's featured card
              if (todayCard != null) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    children: [
                      Icon(Icons.wb_sunny_outlined,
                          size: 20, color: AppColors.gold),
                      const SizedBox(width: 8),
                      Text(
                        '今日推荐',
                        style: AppTypography.headlineSmall.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.gold.withValues(alpha: 0.08),
                        AppColors.primary.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.gold, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              todayCard.category.label,
                              style: TextStyle(
                                fontSize: 10,
                                fontFamily: AppTypography.fontFamily,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          if (todayCard.dateHint != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              todayCard.dateHint!,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textHint,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        todayCard.title,
                        style: AppTypography.headlineMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        todayCard.content,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.8,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // All cards
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Text(
                  '历史知识',
                  style: AppTypography.headlineSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              for (final card in cards)
                HistoryCardWidget(card: card),
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

  Future<void> _toggleNotification(dynamic todayCard) async {
    if (_notificationEnabled) {
      await NotificationService.cancelAll();
      setState(() => _notificationEnabled = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已关闭每日推送')),
        );
      }
    } else {
      final granted = await NotificationService.requestPermission();
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('通知权限未授予，无法开启推送')),
          );
        }
        return;
      }
      final title = todayCard?.title ?? '每日一史';
      final body = todayCard?.content.substring(0, todayCard.content.length > 50 ? 50 : todayCard.content.length) ?? '今天又学到了一条历史知识';
      await NotificationService.scheduleDailyHistory(
        hour: 9,
        minute: 0,
        title: title,
        body: body,
      );
      setState(() => _notificationEnabled = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已开启每日 9:00 推送')),
        );
      }
    }
  }
}
