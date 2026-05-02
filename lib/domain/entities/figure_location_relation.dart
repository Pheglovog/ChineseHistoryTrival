import '../enums/relation_type.dart';

class FigureLocationRelation {
  final int id;
  final int figureId;
  final int locationId;
  final RelationType relationType;
  final String? description;

  const FigureLocationRelation({
    required this.id,
    required this.figureId,
    required this.locationId,
    required this.relationType,
    this.description,
  });

  factory FigureLocationRelation.fromRow(Map<String, dynamic> map) {
    return FigureLocationRelation(
      id: map['id'] as int,
      figureId: map['figure_id'] as int,
      locationId: map['location_id'] as int,
      relationType: RelationTypeHelper.fromString(
        map['relation_type'] as String,
      ),
      description: map['description'] as String?,
    );
  }
}
