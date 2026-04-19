import '../enums/match_source.dart';

class ModernLocation {
  final int id;
  final String name;
  final String? province;
  final String? city;
  final String? district;
  final double latitude;
  final double longitude;
  final String? amapPoiId;
  final MatchSource source;
  final double? confidence;
  final bool verified;

  const ModernLocation({
    required this.id,
    required this.name,
    this.province,
    this.city,
    this.district,
    required this.latitude,
    required this.longitude,
    this.amapPoiId,
    required this.source,
    this.confidence,
    this.verified = false,
  });

  factory ModernLocation.fromRow(Map<String, dynamic> map) {
    return ModernLocation(
      id: map['id'] as int,
      name: map['name'] as String,
      province: map['province'] as String?,
      city: map['city'] as String?,
      district: map['district'] as String?,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      amapPoiId: map['amap_poi_id'] as String?,
      source: MatchSourceHelper.fromString(map['source'] as String),
      confidence: (map['confidence'] as num?)?.toDouble(),
      verified: (map['verified'] as int?) == 1,
    );
  }

  ModernLocation copyWith({
    int? id,
    String? name,
    String? province,
    String? city,
    String? district,
    double? latitude,
    double? longitude,
    String? amapPoiId,
    MatchSource? source,
    double? confidence,
    bool? verified,
  }) {
    return ModernLocation(
      id: id ?? this.id,
      name: name ?? this.name,
      province: province ?? this.province,
      city: city ?? this.city,
      district: district ?? this.district,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      amapPoiId: amapPoiId ?? this.amapPoiId,
      source: source ?? this.source,
      confidence: confidence ?? this.confidence,
      verified: verified ?? this.verified,
    );
  }
}
