import '../enums/admin_level.dart';

class AncientLocation {
  final int id;
  final int dynastyId;
  final String name;
  final String? alias;
  final AdminLevel adminLevel;
  final int? parentLocationId;
  final String? description;
  final int? yearEstablished;
  final int? yearAbolished;
  final String? historicalSignificance;

  const AncientLocation({
    required this.id,
    required this.dynastyId,
    required this.name,
    this.alias,
    required this.adminLevel,
    this.parentLocationId,
    this.description,
    this.yearEstablished,
    this.yearAbolished,
    this.historicalSignificance,
  });

  factory AncientLocation.fromRow(Map<String, dynamic> map) {
    return AncientLocation(
      id: map['id'] as int,
      dynastyId: map['dynasty_id'] as int,
      name: map['name'] as String,
      alias: map['alias'] as String?,
      adminLevel: AdminLevelHelper.fromString(map['admin_level'] as String),
      parentLocationId: map['parent_location_id'] as int?,
      description: map['description'] as String?,
      yearEstablished: map['year_established'] as int?,
      yearAbolished: map['year_abolished'] as int?,
      historicalSignificance: map['historical_significance'] as String?,
    );
  }

  AncientLocation copyWith({
    int? id,
    int? dynastyId,
    String? name,
    String? alias,
    AdminLevel? adminLevel,
    int? parentLocationId,
    String? description,
    int? yearEstablished,
    int? yearAbolished,
    String? historicalSignificance,
  }) {
    return AncientLocation(
      id: id ?? this.id,
      dynastyId: dynastyId ?? this.dynastyId,
      name: name ?? this.name,
      alias: alias ?? this.alias,
      adminLevel: adminLevel ?? this.adminLevel,
      parentLocationId: parentLocationId ?? this.parentLocationId,
      description: description ?? this.description,
      yearEstablished: yearEstablished ?? this.yearEstablished,
      yearAbolished: yearAbolished ?? this.yearAbolished,
      historicalSignificance: historicalSignificance ?? this.historicalSignificance,
    );
  }
}
