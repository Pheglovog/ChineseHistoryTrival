import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../local/database/app_database.dart';
import '../local/database/schema.dart';

class DataSeeder {
  static const String _seedVersionKey = 'seed_version';
  static const int _currentSeedVersion = 1;

  final Future<Database> _dbFuture;

  DataSeeder(AppDatabase appDb) : _dbFuture = AppDatabase.database;

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
    final db = await _dbFuture;
    final jsonStr = await rootBundle.loadString(
      'assets/data/han_dynasty_locations.json',
    );
    final data = json.decode(jsonStr) as Map<String, dynamic>;

    await db.transaction((txn) async {
      // 1. Insert dynasty
      final dynasty = data['dynasty'] as Map<String, dynamic>;
      final dynastyId = await txn.insert(Schema.dynasties, {
        'name': dynasty['name'] as String,
        'name_en': dynasty['nameEn'] as String?,
        'start_year': dynasty['startYear'] as int,
        'end_year': dynasty['endYear'] as int,
        'sub_period': dynasty['subPeriod'] as String?,
        'description': dynasty['description'] as String?,
      });

      // 2. Insert locations recursively
      final locations = data['locations'] as List<dynamic>;
      await _importLocations(txn, locations, dynastyId, null);
    });
  }

  Future<void> _importLocations(
    Transaction txn,
    List<dynamic> locations,
    int dynastyId,
    int? parentLocationId,
  ) async {
    for (final locData in locations) {
      final loc = locData as Map<String, dynamic>;

      final ancientId = await txn.insert(Schema.ancientLocations, {
        'dynasty_id': dynastyId,
        'name': loc['name'] as String,
        'alias': loc['alias'] as String?,
        'admin_level': loc['adminLevel'] as String,
        'parent_location_id': parentLocationId,
        'description': loc['description'] as String?,
        'year_established': loc['yearEstablished'] as int?,
        'year_abolished': loc['yearAbolished'] as int?,
        'historical_significance': loc['historicalSignificance'] as String?,
      });

      final modernMatch = loc['modernMatch'] as Map<String, dynamic>?;
      if (modernMatch != null) {
        final modernId = await txn.insert(Schema.modernLocations, {
          'name': modernMatch['name'] as String,
          'province': modernMatch['province'] as String?,
          'city': modernMatch['city'] as String?,
          'district': modernMatch['district'] as String?,
          'latitude': (modernMatch['latitude'] as num).toDouble(),
          'longitude': (modernMatch['longitude'] as num).toDouble(),
          'amap_poi_id': modernMatch['amapPoiId'] as String?,
          'source': modernMatch['source'] as String? ?? 'manual',
          'confidence': (modernMatch['confidence'] as num?)?.toDouble(),
          'verified': (modernMatch['verified'] as bool? ?? false) ? 1 : 0,
        });

        await txn.insert(Schema.locationMatches, {
          'ancient_location_id': ancientId,
          'modern_location_id': modernId,
          'match_type': modernMatch['matchType'] as String? ?? 'exact',
          'confidence': (modernMatch['confidence'] as num).toDouble(),
          'source': modernMatch['source'] as String? ?? 'manual',
          'notes': modernMatch['notes'] as String?,
          'verified': (modernMatch['verified'] as bool? ?? false) ? 1 : 0,
        });
      }

      final children = loc['children'] as List<dynamic>?;
      if (children != null && children.isNotEmpty) {
        await _importLocations(txn, children, dynastyId, ancientId);
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
