import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart';

import '../local/database/app_database.dart';
import '../local/tables/dynasties_table.dart';
import '../local/tables/ancient_locations_table.dart';
import '../local/tables/modern_locations_table.dart';
import '../local/tables/location_matches_table.dart';

class DataSeeder {
  static const String _seedVersionKey = 'seed_version';
  static const int _currentSeedVersion = 1;

  final AppDatabase _db;

  DataSeeder(this._db);

  /// Check if seed data needs to be imported and import if needed.
  /// Returns true if data was imported, false if skipped.
  Future<bool> seedIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final currentVersion = prefs.getInt(_seedVersionKey);

    if (currentVersion == _currentSeedVersion) {
      return false;
    }

    await _importSeedData();

    await prefs.setInt(_seedVersionKey, _currentSeedVersion);
    return true;
  }

  Future<void> _importSeedData() async {
    final jsonStr = await rootBundle.loadString(
      'assets/data/han_dynasty_locations.json',
    );
    final data = json.decode(jsonStr) as Map<String, dynamic>;

    await _db.transaction(() async {
      // 1. Insert dynasty
      final dynasty = data['dynasty'] as Map<String, dynamic>;
      final dynastyId = await _db.into(_db.dynasties).insert(
            DynastiesCompanion.insert(
              name: dynasty['name'] as String,
              nameEn: Value(dynasty['nameEn'] as String?),
              startYear: dynasty['startYear'] as int,
              endYear: dynasty['endYear'] as int,
              subPeriod: Value(dynasty['subPeriod'] as String?),
              description: Value(dynasty['description'] as String?),
            ),
          );

      // 2. Insert locations recursively
      final locations = data['locations'] as List<dynamic>;
      await _importLocations(locations, dynastyId, null);
    });
  }

  Future<void> _importLocations(
    List<dynamic> locations,
    int dynastyId,
    int? parentLocationId,
  ) async {
    for (final locData in locations) {
      final loc = locData as Map<String, dynamic>;

      // Insert ancient location
      final ancientId = await _db.into(_db.ancientLocations).insert(
            AncientLocationsCompanion.insert(
              dynastyId: dynastyId,
              name: loc['name'] as String,
              alias: Value(loc['alias'] as String?),
              adminLevel: loc['adminLevel'] as String,
              parentLocationId: Value(parentLocationId),
              description: Value(loc['description'] as String?),
              yearEstablished: Value(loc['yearEstablished'] as int?),
              yearAbolished: Value(loc['yearAbolished'] as int?),
              historicalSignificance:
                  Value(loc['historicalSignificance'] as String?),
            ),
          );

      // Insert modern match if present
      final modernMatch = loc['modernMatch'] as Map<String, dynamic>?;
      if (modernMatch != null) {
        final modernId = await _db.into(_db.modernLocations).insert(
              ModernLocationsCompanion.insert(
                name: modernMatch['name'] as String,
                province: Value(modernMatch['province'] as String?),
                city: Value(modernMatch['city'] as String?),
                district: Value(modernMatch['district'] as String?),
                latitude: (modernMatch['latitude'] as num).toDouble(),
                longitude: (modernMatch['longitude'] as num).toDouble(),
                amapPoiId: Value(modernMatch['amapPoiId'] as String?),
                source: modernMatch['source'] as String? ?? 'manual',
                confidence: Value(
                  (modernMatch['confidence'] as num?)?.toDouble(),
                ),
                verified: Value(modernMatch['verified'] as bool? ?? false),
              ),
            );

        // Insert match relation
        await _db.into(_db.locationMatches).insert(
              LocationMatchesCompanion.insert(
                ancientLocationId: ancientId,
                modernLocationId: modernId,
                matchType: modernMatch['matchType'] as String? ?? 'exact',
                confidence: (modernMatch['confidence'] as num).toDouble(),
                source: modernMatch['source'] as String? ?? 'manual',
                notes: Value(modernMatch['notes'] as String?),
                verified: Value(modernMatch['verified'] as bool? ?? false),
              ),
            );
      }

      // Recursively import children
      final children = loc['children'] as List<dynamic>?;
      if (children != null && children.isNotEmpty) {
        await _importLocations(children, dynastyId, ancientId);
      }
    }
  }

  /// Force re-import seed data (for development/debugging)
  Future<void> forceReseed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_seedVersionKey);
    await seedIfNeeded();
  }
}
