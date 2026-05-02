class RouteStop {
  final int id;
  final int routeId;
  final int orderIndex;
  final int locationId;
  final int? modernLocationId;
  final String? title;
  final String? description;
  final String? arrivalStory;
  final int? stayDuration;

  const RouteStop({
    required this.id,
    required this.routeId,
    required this.orderIndex,
    required this.locationId,
    this.modernLocationId,
    this.title,
    this.description,
    this.arrivalStory,
    this.stayDuration,
  });

  factory RouteStop.fromRow(Map<String, dynamic> map) {
    return RouteStop(
      id: map['id'] as int,
      routeId: map['route_id'] as int,
      orderIndex: map['order_index'] as int,
      locationId: map['location_id'] as int,
      modernLocationId: map['modern_location_id'] as int?,
      title: map['title'] as String?,
      description: map['description'] as String?,
      arrivalStory: map['arrival_story'] as String?,
      stayDuration: map['stay_duration'] as int?,
    );
  }
}
