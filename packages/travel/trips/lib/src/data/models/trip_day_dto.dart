import '../../domain/entities/trip_day_entity.dart';
import 'itinerary_item_dto.dart';

class TripDayDto {
  final String id;
  final String tripId;
  final int dayNumber;
  final String? date;
  final String? title;
  final String? description;
  final List<ItineraryItemDto> items;

  const TripDayDto({
    required this.id,
    required this.tripId,
    required this.dayNumber,
    this.date,
    this.title,
    this.description,
    this.items = const [],
  });

  factory TripDayDto.fromJson(Map<String, dynamic> json) {
    return TripDayDto(
      id: json['id'] as String? ?? '',
      tripId: json['tripId'] as String? ?? '',
      dayNumber: json['dayNumber'] as int? ?? 1,
      date: json['date'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => ItineraryItemDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tripId': tripId,
      'dayNumber': dayNumber,
      'date': date,
      'title': title,
      'description': description,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }

  TripDayEntity toEntity() {
    return TripDayEntity(
      id: id,
      tripId: tripId,
      dayNumber: dayNumber,
      date: date != null ? DateTime.tryParse(date!) : null,
      title: title,
      description: description,
      items: items.map((e) => e.toEntity()).toList(),
    );
  }
}
