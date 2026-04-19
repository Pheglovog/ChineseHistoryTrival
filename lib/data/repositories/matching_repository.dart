import 'package:drift/drift.dart';

import '../local/database/app_database.dart';
import '../local/tables/modern_locations_table.dart';
import '../local/tables/location_matches_table.dart';

/// Internal class representing a known ancient-to-modern mapping.
class _KnownMapping {
  final String name;
  final double lat;
  final double lng;
  final String province;
  const _KnownMapping(this.name, this.lat, this.lng, this.province);
}

class MatchingRepository {
  final AppDatabase _db;

  /// Known mappings for names that changed completely.
  static const Map<String, _KnownMapping> _knownMappings = {
    '长安': _KnownMapping('西安市', 34.26, 108.93, '陕西省'),
    '洛阳': _KnownMapping('洛阳市', 34.62, 112.45, '河南省'),
    '彭城': _KnownMapping('徐州市', 34.26, 117.18, '江苏省'),
    '建康': _KnownMapping('南京市', 32.06, 118.80, '江苏省'),
    '临淄': _KnownMapping('淄博市临淄区', 36.83, 118.31, '山东省'),
    '邺城': _KnownMapping('邯郸市临漳县', 36.23, 114.61, '河北省'),
    '宛': _KnownMapping('南阳市', 33.00, 112.53, '河南省'),
    '江陵': _KnownMapping('荆州市', 30.33, 112.24, '湖北省'),
  };

  MatchingRepository(this._db);

  /// Match an ancient location to modern coordinates.
  /// Returns the LocationMatch if found, null otherwise.
  Future<LocationMatch?> match(AncientLocation ancient) async {
    // 0. Check cache first
    final cached = await _db.locationMatchDao.getCachedMatch(ancient.id);
    if (cached != null) return cached;

    // Level 1: Exact name match (strip suffixes like 市/区/县)
    final exact = await _exactMatch(ancient.name);
    if (exact != null) {
      return _saveMatch(ancient.id, exact, 'exact', 0.95, 'manual');
    }

    // Level 2: Substring/similarity match
    final similar = await _substringMatch(ancient.name);
    if (similar != null) {
      return _saveMatch(ancient.id, similar, 'approximate', 0.7, 'manual');
    }

    // Level 3: Known mapping dictionary
    final mapped = _dictionaryMatch(ancient.name);
    if (mapped != null) {
      return _saveKnownMapping(ancient.id, mapped);
    }

    return null; // Needs AI fallback
  }

  /// Level 1: Exact name comparison with suffix stripping
  Future<ModernLocation?> _exactMatch(String ancientName) async {
    final cleanName = _stripSuffix(ancientName);
    final results = await _db.modernLocationDao.getByName(ancientName);

    for (final loc in results) {
      final cleanModern = _stripSuffix(loc.name);
      if (cleanName == cleanModern) return loc;
    }
    return null;
  }

  /// Level 2: Check if ancient name is substring of modern name
  Future<ModernLocation?> _substringMatch(String ancientName) async {
    final results = await _db.modernLocationDao.getByName(ancientName);
    for (final loc in results) {
      if (loc.name.contains(ancientName) ||
          ancientName.contains(_stripSuffix(loc.name))) {
        return loc;
      }
    }
    return null;
  }

  /// Level 3: Known mapping dictionary
  _KnownMapping? _dictionaryMatch(String ancientName) {
    return _knownMappings[ancientName];
  }

  /// Save a match to cache
  Future<LocationMatch> _saveMatch(
    int ancientId,
    ModernLocation modern,
    String matchType,
    double confidence,
    String source,
  ) async {
    final id = await _db.locationMatchDao.insert(
      LocationMatchesCompanion.insert(
        ancientLocationId: ancientId,
        modernLocationId: modern.id,
        matchType: matchType,
        confidence: confidence,
        source: source,
      ),
    );
    return (await (_db.select(_db.locationMatches)
          ..where((t) => t.id.equals(id)))
        .getSingle());
  }

  /// Save a known mapping match (creates modern location + match)
  Future<LocationMatch> _saveKnownMapping(
    int ancientId,
    _KnownMapping mapping,
  ) async {
    // Check if modern location already exists
    final existing = await _db.modernLocationDao.getByNameExact(mapping.name);
    int modernId;
    if (existing != null) {
      modernId = existing.id;
    } else {
      modernId = await _db.modernLocationDao.insert(
        ModernLocationsCompanion.insert(
          name: mapping.name,
          province: Value(mapping.province),
          latitude: mapping.lat,
          longitude: mapping.lng,
          source: 'manual',
        ),
      );
    }
    final id = await _db.locationMatchDao.insert(
      LocationMatchesCompanion.insert(
        ancientLocationId: ancientId,
        modernLocationId: modernId,
        matchType: 'exact',
        confidence: 0.9,
        source: 'manual',
      ),
    );
    return (await (_db.select(_db.locationMatches)
          ..where((t) => t.id.equals(id)))
        .getSingle());
  }

  /// Strip common Chinese administrative suffixes
  String _stripSuffix(String name) {
    return name.replaceAll(RegExp(r'(市|区|县|省|镇|乡|路|街|道)$'), '');
  }
}
