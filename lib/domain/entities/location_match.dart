import '../enums/match_type.dart';
import '../enums/match_source.dart';

class LocationMatch {
  final int id;
  final int ancientLocationId;
  final int modernLocationId;
  final MatchType matchType;
  final double confidence;
  final MatchSource source;
  final String? notes;
  final bool verified;
  final DateTime createdAt;

  const LocationMatch({
    required this.id,
    required this.ancientLocationId,
    required this.modernLocationId,
    required this.matchType,
    required this.confidence,
    required this.source,
    this.notes,
    this.verified = false,
    required this.createdAt,
  });

  factory LocationMatch.fromRow(Map<String, dynamic> map) {
    return LocationMatch(
      id: map['id'] as int,
      ancientLocationId: map['ancient_location_id'] as int,
      modernLocationId: map['modern_location_id'] as int,
      matchType: MatchTypeHelper.fromString(map['match_type'] as String),
      confidence: (map['confidence'] as num).toDouble(),
      source: MatchSourceHelper.fromString(map['source'] as String),
      notes: map['notes'] as String?,
      verified: (map['verified'] as int?) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  LocationMatch copyWith({
    int? id,
    int? ancientLocationId,
    int? modernLocationId,
    MatchType? matchType,
    double? confidence,
    MatchSource? source,
    String? notes,
    bool? verified,
    DateTime? createdAt,
  }) {
    return LocationMatch(
      id: id ?? this.id,
      ancientLocationId: ancientLocationId ?? this.ancientLocationId,
      modernLocationId: modernLocationId ?? this.modernLocationId,
      matchType: matchType ?? this.matchType,
      confidence: confidence ?? this.confidence,
      source: source ?? this.source,
      notes: notes ?? this.notes,
      verified: verified ?? this.verified,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
