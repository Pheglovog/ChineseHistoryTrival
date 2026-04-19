import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/database/app_database.dart';

/// Drift database singleton
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});
