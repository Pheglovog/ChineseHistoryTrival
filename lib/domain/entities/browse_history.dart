class BrowseHistory {
  final int id;
  final int locationId;
  final int dynastyId;
  final DateTime visitedAt;

  const BrowseHistory({
    required this.id,
    required this.locationId,
    required this.dynastyId,
    required this.visitedAt,
  });

  factory BrowseHistory.fromRow(Map<String, dynamic> map) {
    return BrowseHistory(
      id: map['id'] as int,
      locationId: map['location_id'] as int,
      dynastyId: map['dynasty_id'] as int,
      visitedAt: DateTime.parse(map['visited_at'] as String),
    );
  }
}
