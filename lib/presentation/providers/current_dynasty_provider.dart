import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/database/app_database.dart';
import 'database_provider.dart';

/// Current selected dynasty ID
final currentDynastyIdProvider = StateProvider<int>((ref) => 1); // Default: Han Dynasty

/// Current dynasty data
final currentDynastyProvider = StreamProvider<Dynasty?>((ref) {
  final db = ref.watch(databaseProvider);
  final dynastyId = ref.watch(currentDynastyIdProvider);
  return db.dynastyDao.watchAllDynasties().map(
    (dynasties) => dynasties.where((d) => d.id == dynastyId).firstOrNull,
  );
});
