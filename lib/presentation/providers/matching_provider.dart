import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/ancient_location.dart';
import '../../data/repositories/matching_repository.dart';
import '../../data/local/database/app_database.dart';
import 'database_provider.dart';

enum MatchingStatus { idle, matching, done, error }

class MatchingState {
  final MatchingStatus status;
  final int total;
  final int matched;
  final String? error;

  const MatchingState({
    this.status = MatchingStatus.idle,
    this.total = 0,
    this.matched = 0,
    this.error,
  });

  MatchingState copyWith({
    MatchingStatus? status,
    int? total,
    int? matched,
    String? error,
  }) {
    return MatchingState(
      status: status ?? this.status,
      total: total ?? this.total,
      matched: matched ?? this.matched,
      error: error ?? this.error,
    );
  }
}

final matchingWorkflowProvider =
    StateNotifierProvider<MatchingWorkflowNotifier, MatchingState>((ref) {
  return MatchingWorkflowNotifier(ref.watch(databaseProvider));
});

class MatchingWorkflowNotifier extends StateNotifier<MatchingState> {
  late final MatchingRepository _matchingRepo;

  MatchingWorkflowNotifier(AppDatabase _) : super(const MatchingState()) {
    _matchingRepo = MatchingRepository(AppDatabase.database);
  }

  Future<void> runMatching(List<AncientLocation> locations) async {
    state = MatchingState(
      status: MatchingStatus.matching,
      total: locations.length,
    );
    int matched = 0;
    for (final loc in locations) {
      try {
        await _matchingRepo.match(loc);
        matched++;
      } catch (_) {}
      state = state.copyWith(matched: matched);
    }
    state = state.copyWith(status: MatchingStatus.done);
  }
}
