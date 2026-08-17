import 'itinerary_item_entity.dart';

class TripDayEntity {
  final String id;
  final String tripId;
  final int dayNumber;
  final DateTime? date;
  final String? title;
  final String? description;
  final List<ItineraryItemEntity> items;

  const TripDayEntity({
    required this.id,
    required this.tripId,
    required this.dayNumber,
    this.date,
    this.title,
    this.description,
    this.items = const [],
  });

  TripDayEntity copyWith({
    int? dayNumber,
    DateTime? date,
    String? title,
    String? description,
    List<ItineraryItemEntity>? items,
  }) {
    return TripDayEntity(
      id: id,
      tripId: tripId,
      dayNumber: dayNumber ?? this.dayNumber,
      date: date ?? this.date,
      title: title ?? this.title,
      description: description ?? this.description,
      items: items ?? this.items,
    );
  }
}
