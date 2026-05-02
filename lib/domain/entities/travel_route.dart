import '../enums/route_difficulty.dart';

class TravelRoute {
  final int id;
  final int dynastyId;
  final String name;
  final String? description;
  final int? figureId;
  final String? coverStory;
  final RouteDifficulty difficulty;
  final int estimatedDays;
  final bool isCustom;
  final DateTime? createdAt;

  const TravelRoute({
    required this.id,
    required this.dynastyId,
    required this.name,
    this.description,
    this.figureId,
    this.coverStory,
    this.difficulty = RouteDifficulty.medium,
    this.estimatedDays = 1,
    this.isCustom = false,
    this.createdAt,
  });

  factory TravelRoute.fromRow(Map<String, dynamic> map) {
    return TravelRoute(
      id: map['id'] as int,
      dynastyId: map['dynasty_id'] as int,
      name: map['name'] as String,
      description: map['description'] as String?,
      figureId: map['figure_id'] as int?,
      coverStory: map['cover_story'] as String?,
      difficulty: RouteDifficultyHelper.fromString(
        map['difficulty'] as String? ?? 'medium',
      ),
      estimatedDays: map['estimated_days'] as int? ?? 1,
      isCustom: (map['is_custom'] as int?) == 1,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }
}
