import '../enums/history_card_category.dart';

class HistoryCard {
  final int id;
  final int dynastyId;
  final String title;
  final String content;
  final int? figureId;
  final int? locationId;
  final String? dateHint;
  final HistoryCardCategory category;

  const HistoryCard({
    required this.id,
    required this.dynastyId,
    required this.title,
    required this.content,
    this.figureId,
    this.locationId,
    this.dateHint,
    this.category = HistoryCardCategory.event,
  });

  factory HistoryCard.fromRow(Map<String, dynamic> map) {
    return HistoryCard(
      id: map['id'] as int,
      dynastyId: map['dynasty_id'] as int,
      title: map['title'] as String,
      content: map['content'] as String,
      figureId: map['figure_id'] as int?,
      locationId: map['location_id'] as int?,
      dateHint: map['date_hint'] as String?,
      category: HistoryCardCategoryHelper.fromString(
        map['category'] as String? ?? 'event',
      ),
    );
  }
}
