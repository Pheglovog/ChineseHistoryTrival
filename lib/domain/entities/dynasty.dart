class Dynasty {
  final int id;
  final String name;
  final String? nameEn;
  final int startYear;
  final int endYear;
  final String? subPeriod;
  final String? description;

  const Dynasty({
    required this.id,
    required this.name,
    this.nameEn,
    required this.startYear,
    required this.endYear,
    this.subPeriod,
    this.description,
  });

  factory Dynasty.fromRow(Map<String, dynamic> map) {
    return Dynasty(
      id: map['id'] as int,
      name: map['name'] as String,
      nameEn: map['name_en'] as String?,
      startYear: map['start_year'] as int,
      endYear: map['end_year'] as int,
      subPeriod: map['sub_period'] as String?,
      description: map['description'] as String?,
    );
  }

  Dynasty copyWith({
    int? id,
    String? name,
    String? nameEn,
    int? startYear,
    int? endYear,
    String? subPeriod,
    String? description,
  }) {
    return Dynasty(
      id: id ?? this.id,
      name: name ?? this.name,
      nameEn: nameEn ?? this.nameEn,
      startYear: startYear ?? this.startYear,
      endYear: endYear ?? this.endYear,
      subPeriod: subPeriod ?? this.subPeriod,
      description: description ?? this.description,
    );
  }
}
