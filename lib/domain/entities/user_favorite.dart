class UserFavorite {
  final int id;
  final int locationId;
  final int dynastyId;
  final DateTime createdAt;

  const UserFavorite({
    required this.id,
    required this.locationId,
    required this.dynastyId,
    required this.createdAt,
  });

  factory UserFavorite.fromRow(Map<String, dynamic> map) {
    return UserFavorite(
      id: map['id'] as int,
      locationId: map['location_id'] as int,
      dynastyId: map['dynasty_id'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
