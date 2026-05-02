import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/history_card.dart';
import 'database_provider.dart';
import 'current_dynasty_provider.dart';

final historyCardsProvider =
    FutureProvider<List<HistoryCard>>((ref) async {
  final db = ref.watch(databaseProvider);
  final dynastyId = ref.watch(currentDynastyIdProvider);
  final dao = await db.historyCardDao;
  return dao.getByDynasty(dynastyId);
});

final todayCardProvider = FutureProvider<HistoryCard?>((ref) async {
  final cards = await ref.watch(historyCardsProvider.future);
  if (cards.isEmpty) return null;
  final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
  return cards[dayOfYear % cards.length];
});
