import '../enums/figure_category.dart';

class HistoricalFigure {
  final int id;
  final int dynastyId;
  final String name;
  final String? alias;
  final String? title;
  final int? birthYear;
  final int? deathYear;
  final FigureCategory category;
  final String? description;
  final String? biography;

  const HistoricalFigure({
    required this.id,
    required this.dynastyId,
    required this.name,
    this.alias,
    this.title,
    this.birthYear,
    this.deathYear,
    this.category = FigureCategory.other,
    this.description,
    this.biography,
  });

  factory HistoricalFigure.fromRow(Map<String, dynamic> map) {
    return HistoricalFigure(
      id: map['id'] as int,
      dynastyId: map['dynasty_id'] as int,
      name: map['name'] as String,
      alias: map['alias'] as String?,
      title: map['title'] as String?,
      birthYear: map['birth_year'] as int?,
      deathYear: map['death_year'] as int?,
      category: FigureCategoryHelper.fromString(
        map['category'] as String? ?? 'other',
      ),
      description: map['description'] as String?,
      biography: map['biography'] as String?,
    );
  }
}
