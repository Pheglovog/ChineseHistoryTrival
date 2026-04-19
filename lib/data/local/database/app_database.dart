import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../tables/dynasties_table.dart';
import '../tables/ancient_locations_table.dart';
import '../tables/modern_locations_table.dart';
import '../tables/location_matches_table.dart';
import '../daos/dynasty_dao.dart';
import '../daos/ancient_location_dao.dart';
import '../daos/modern_location_dao.dart';
import '../daos/location_match_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Dynasties,
    AncientLocations,
    ModernLocations,
    LocationMatches,
  ],
  daos: [
    DynastyDao,
    AncientLocationDao,
    ModernLocationDao,
    LocationMatchDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          // Future migrations go here
        },
      );

  // DAO accessors
  DynastyDao get dynastyDao => DynastyDao(this);
  AncientLocationDao get ancientLocationDao => AncientLocationDao(this);
  ModernLocationDao get modernLocationDao => ModernLocationDao(this);
  LocationMatchDao get locationMatchDao => LocationMatchDao(this);
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'huaxia_footprint.db'));
    return NativeDatabase.createInBackground(file);
  });
}
