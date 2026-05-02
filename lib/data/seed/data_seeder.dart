import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../local/database/app_database.dart';
import '../local/database/schema.dart';

class DataSeeder {
  static const String _seedVersionKey = 'seed_version';
  static const int _currentSeedVersion = 2;

  final Future<Database> _dbFuture;

  DataSeeder(AppDatabase appDb) : _dbFuture = AppDatabase.database;

  /// Check if seed data needs to be imported and import if needed.
  Future<bool> seedIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final currentVersion = prefs.getInt(_seedVersionKey);

    if (currentVersion == _currentSeedVersion) {
      return false;
    }

    await _importAllSeedData(currentVersion ?? 0);

    await prefs.setInt(_seedVersionKey, _currentSeedVersion);
    return true;
  }

  Future<void> _importAllSeedData(int fromVersion) async {
    final db = await _dbFuture;

    // Import dynasty location data (supports multiple dynasties)
    final dynastyFiles = [
      'assets/data/han_dynasty_locations.json',
      'assets/data/tang_dynasty_locations.json',
      'assets/data/song_dynasty_locations.json',
    ];

    for (final filePath in dynastyFiles) {
      try {
        final jsonStr = await rootBundle.loadString(filePath);
        final data = json.decode(jsonStr) as Map<String, dynamic>;
        await _importDynastyData(db, data);
      } catch (e) {
        // Skip missing files gracefully
        continue;
      }
    }

    // Import supplementary data (only if upgrading to v2+)
    if (fromVersion < 2) {
      await _importSupplementaryData(db);
    }
  }

  Future<void> _importDynastyData(
    Database db,
    Map<String, dynamic> data,
  ) async {
    await db.transaction((txn) async {
      // Check if dynasty already exists
      final dynasty = data['dynasty'] as Map<String, dynamic>;
      final existing = await txn.query(
        Schema.dynasties,
        where: 'name = ?',
        whereArgs: [dynasty['name'] as String],
      );

      int dynastyId;
      if (existing.isEmpty) {
        dynastyId = await txn.insert(Schema.dynasties, {
          'name': dynasty['name'] as String,
          'name_en': dynasty['nameEn'] as String?,
          'start_year': dynasty['startYear'] as int,
          'end_year': dynasty['endYear'] as int,
          'sub_period': dynasty['subPeriod'] as String?,
          'description': dynasty['description'] as String?,
        });
      } else {
        dynastyId = existing.first['id'] as int;
      }

      // Import locations
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

  Future<void> _importSupplementaryData(Database db) async {
    // Import historical figures
    await _importJsonFile(
      db,
      'assets/data/han_historical_figures.json',
      (data, txn) async {
        final figures = data['figures'] as List<dynamic>;
        for (final figData in figures) {
          final fig = figData as Map<String, dynamic>;
          final figureId = await txn.insert(Schema.historicalFigures, {
            'dynasty_id': 1, // Han dynasty
            'name': fig['name'] as String,
            'alias': fig['alias'] as String?,
            'title': fig['title'] as String?,
            'birth_year': fig['birthYear'] as int?,
            'death_year': fig['deathYear'] as int?,
            'category': fig['category'] as String? ?? 'other',
            'description': fig['description'] as String?,
            'biography': fig['biography'] as String?,
          });

          // Import location relations
          final relations = fig['locationRelations'] as List<dynamic>?;
          if (relations != null) {
            for (final relData in relations) {
              final rel = relData as Map<String, dynamic>;
              // Find location by name
              final locationRows = await txn.query(
                Schema.ancientLocations,
                where: 'name = ? AND dynasty_id = 1',
                whereArgs: [rel['locationName'] as String],
                limit: 1,
              );
              if (locationRows.isNotEmpty) {
                await txn.insert(Schema.figureLocationRelations, {
                  'figure_id': figureId,
                  'location_id': locationRows.first['id'] as int,
                  'relation_type': rel['relationType'] as String,
                  'description': rel['description'] as String?,
                });
              }
            }
          }
        }
      },
    );

    // Import travel routes
    await _importJsonFile(
      db,
      'assets/data/han_travel_routes.json',
      (data, txn) async {
        final routes = data['routes'] as List<dynamic>;
        for (final routeData in routes) {
          final route = routeData as Map<String, dynamic>;

          // Find figure by name if specified
          int? figureId;
          final figureName = route['figureName'] as String?;
          if (figureName != null) {
            final figRows = await txn.query(
              Schema.historicalFigures,
              where: 'name = ?',
              whereArgs: [figureName],
              limit: 1,
            );
            if (figRows.isNotEmpty) {
              figureId = figRows.first['id'] as int;
            }
          }

          final routeId = await txn.insert(Schema.travelRoutes, {
            'dynasty_id': 1,
            'name': route['name'] as String,
            'description': route['description'] as String?,
            'figure_id': figureId,
            'cover_story': route['coverStory'] as String?,
            'difficulty': route['difficulty'] as String? ?? 'medium',
            'estimated_days': route['estimatedDays'] as int? ?? 1,
            'is_custom': 0,
          });

          // Import route stops
          final stops = route['stops'] as List<dynamic>;
          for (final stopData in stops) {
            final stop = stopData as Map<String, dynamic>;
            // Find location by name
            final locRows = await txn.query(
              Schema.ancientLocations,
              where: 'name = ? AND dynasty_id = 1',
              whereArgs: [stop['locationName'] as String],
              limit: 1,
            );
            int? locationId;
            int? modernLocationId;
            if (locRows.isNotEmpty) {
              locationId = locRows.first['id'] as int;
              // Find modern match
              final matchRows = await txn.query(
                Schema.locationMatches,
                where: 'ancient_location_id = ?',
                whereArgs: [locationId],
                limit: 1,
              );
              if (matchRows.isNotEmpty) {
                modernLocationId = matchRows.first['modern_location_id'] as int;
              }
            }

            await txn.insert(Schema.routeStops, {
              'route_id': routeId,
              'order_index': stop['orderIndex'] as int,
              'location_id': locationId ?? 0,
              'modern_location_id': modernLocationId,
              'title': stop['title'] as String?,
              'description': stop['description'] as String?,
              'arrival_story': stop['arrivalStory'] as String?,
              'stay_duration': stop['stayDuration'] as int?,
            });
          }
        }
      },
    );

    // Import history cards
    await _importJsonFile(
      db,
      'assets/data/history_cards.json',
      (data, txn) async {
        final cards = data['cards'] as List<dynamic>;
        for (final cardData in cards) {
          final card = cardData as Map<String, dynamic>;

          // Find figure by name if specified
          int? figureId;
          final figureName = card['figureName'] as String?;
          if (figureName != null) {
            final figRows = await txn.query(
              Schema.historicalFigures,
              where: 'name = ?',
              whereArgs: [figureName],
              limit: 1,
            );
            if (figRows.isNotEmpty) {
              figureId = figRows.first['id'] as int;
            }
          }

          // Find location by name if specified
          int? locationId;
          final locationName = card['locationName'] as String?;
          if (locationName != null) {
            final locRows = await txn.query(
              Schema.ancientLocations,
              where: 'name = ?',
              whereArgs: [locationName],
              limit: 1,
            );
            if (locRows.isNotEmpty) {
              locationId = locRows.first['id'] as int;
            }
          }

          await txn.insert(Schema.historyCards, {
            'dynasty_id': 1,
            'title': card['title'] as String,
            'content': card['content'] as String,
            'figure_id': figureId,
            'location_id': locationId,
            'date_hint': card['dateHint'] as String?,
            'category': card['category'] as String? ?? 'event',
          });
        }
      },
    );
  }

  Future<void> _importJsonFile(
    Database db,
    String filePath,
    Future<void> Function(Map<String, dynamic>, Transaction) importer,
  ) async {
    try {
      final jsonStr = await rootBundle.loadString(filePath);
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      await db.transaction((txn) async {
        await importer(data, txn);
      });
    } catch (e) {
      // Skip missing or invalid files gracefully
    }
  }

  /// Force re-import seed data (for development/debugging)
  Future<void> forceReseed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_seedVersionKey);
    await seedIfNeeded();
  }
}
