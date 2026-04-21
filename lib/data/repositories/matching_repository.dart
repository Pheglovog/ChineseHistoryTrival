import 'package:sqflite/sqflite.dart';

import '../../domain/entities/ancient_location.dart';
import '../../domain/entities/modern_location.dart';
import '../../domain/entities/location_match.dart';
import '../local/database/schema.dart';

/// Internal class representing a known ancient-to-modern mapping.
class _KnownMapping {
  final String name;
  final double lat;
  final double lng;
  final String province;
  const _KnownMapping(this.name, this.lat, this.lng, this.province);
}

class MatchingRepository {
  final Future<Database> _dbFuture;

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

  MatchingRepository(this._dbFuture);

  /// Match an ancient location to modern coordinates.
  /// Returns the LocationMatch if found, null otherwise.
  Future<LocationMatch?> match(AncientLocation ancient) async {
    final db = await _dbFuture;

    // Check cache first
    final cachedRows = await db.query(
      Schema.locationMatches,
      where: 'ancient_location_id = ? AND verified = 1',
      whereArgs: [ancient.id],
      orderBy: 'confidence DESC',
      limit: 1,
    );
    if (cachedRows.isNotEmpty) {
      return LocationMatch.fromRow(cachedRows.first);
    }

    // Level 1: Exact name match
    final exact = await _exactMatch(ancient.name);
    if (exact != null) {
      return _saveMatch(ancient.id, exact, 'exact', 0.95, 'manual');
    }

    // Level 2: Substring match
    final similar = await _substringMatch(ancient.name);
    if (similar != null) {
      return _saveMatch(ancient.id, similar, 'approximate', 0.7, 'manual');
    }

    // Level 3: Known mapping dictionary
    final mapped = _knownMappings[ancient.name];
    if (mapped != null) {
      return _saveKnownMapping(ancient.id, mapped);
    }

    return null;
  }

  Future<ModernLocation?> _exactMatch(String ancientName) async {
    final db = await _dbFuture;
    final cleanName = _stripSuffix(ancientName);
    final rows = await db.query(
      Schema.modernLocations,
      where: 'name LIKE ?',
      whereArgs: ['%$ancientName%'],
    );
    for (final row in rows) {
      final loc = ModernLocation.fromRow(row);
      if (_stripSuffix(loc.name) == cleanName) return loc;
    }
    return null;
  }

  Future<ModernLocation?> _substringMatch(String ancientName) async {
    final db = await _dbFuture;
    final rows = await db.query(
      Schema.modernLocations,
      where: 'name LIKE ?',
      whereArgs: ['%$ancientName%'],
    );
    for (final row in rows) {
      final loc = ModernLocation.fromRow(row);
      if (loc.name.contains(ancientName) ||
          ancientName.contains(_stripSuffix(loc.name))) {
        return loc;
      }
    }
    return null;
  }

  Future<LocationMatch> _saveMatch(
    int ancientId,
    ModernLocation modern,
    String matchType,
    double confidence,
    String source,
  ) async {
    final db = await _dbFuture;
    final id = await db.insert(Schema.locationMatches, {
      'ancient_location_id': ancientId,
      'modern_location_id': modern.id,
      'match_type': matchType,
      'confidence': confidence,
      'source': source,
    });
    final rows = await db.query(
      Schema.locationMatches,
      where: 'id = ?',
      whereArgs: [id],
    );
    return LocationMatch.fromRow(rows.first);
  }

  Future<LocationMatch> _saveKnownMapping(
    int ancientId,
    _KnownMapping mapping,
  ) async {
    final db = await _dbFuture;
    final existingRows = await db.query(
      Schema.modernLocations,
      where: 'name = ?',
      whereArgs: [mapping.name],
    );
    int modernId;
    if (existingRows.isNotEmpty) {
      modernId = existingRows.first['id'] as int;
    } else {
      modernId = await db.insert(Schema.modernLocations, {
        'name': mapping.name,
        'province': mapping.province,
        'latitude': mapping.lat,
        'longitude': mapping.lng,
        'source': 'manual',
      });
    }
    final id = await db.insert(Schema.locationMatches, {
      'ancient_location_id': ancientId,
      'modern_location_id': modernId,
      'match_type': 'exact',
      'confidence': 0.9,
      'source': 'manual',
    });
    final rows = await db.query(
      Schema.locationMatches,
      where: 'id = ?',
      whereArgs: [id],
    );
    return LocationMatch.fromRow(rows.first);
  }

  String _stripSuffix(String name) {
    return name.replaceAll(RegExp(r'(市|区|县|省|镇|乡|路|街|道)$'), '');
  }
}
