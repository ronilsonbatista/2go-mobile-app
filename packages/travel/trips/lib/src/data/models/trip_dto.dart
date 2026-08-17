import '../../domain/entities/trip_entity.dart';
import 'trip_day_dto.dart';

class TripDto {
  final String id;
  final String userId;
  final String title;
  final String destination;
  final String? coverImage;
  final String? startDate;
  final String? endDate;
  final String status;
  final Map<String, dynamic>? preferences;
  final String? premiumUnlockedAt;
  final List<TripDayDto> days;

  const TripDto({
    required this.id,
    required this.userId,
    required this.title,
    required this.destination,
    this.coverImage,
    this.startDate,
    this.endDate,
    this.status = 'DRAFT',
    this.preferences,
    this.premiumUnlockedAt,
    this.days = const [],
  });

  factory TripDto.fromJson(Map<String, dynamic> json) {
    return TripDto(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      destination: json['destination'] as String? ?? '',
      coverImage: json['coverImage'] as String?,
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      status: json['status'] as String? ?? 'DRAFT',
      preferences: json['preferences'] as Map<String, dynamic>?,
      premiumUnlockedAt: json['premiumUnlockedAt'] as String?,
      days:
          (json['days'] as List<dynamic>?)
              ?.map((e) => TripDayDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'destination': destination,
      'coverImage': coverImage,
      'startDate': startDate,
      'endDate': endDate,
      'status': status,
      'preferences': preferences,
      'premiumUnlockedAt': premiumUnlockedAt,
      'days': days.map((e) => e.toJson()).toList(),
    };
  }

  TripEntity toEntity() {
    return TripEntity(
      id: id,
      userId: userId,
      title: title,
      destination: destination,
      coverImage: coverImage,
      startDate: startDate != null ? DateTime.tryParse(startDate!) : null,
      endDate: endDate != null ? DateTime.tryParse(endDate!) : null,
      status: _mapStatus(status),
      preferences: preferences,
      premiumUnlockedAt: premiumUnlockedAt != null
          ? DateTime.tryParse(premiumUnlockedAt!)
          : null,
      days: days.map((e) => e.toEntity()).toList(),
    );
  }

  static TripStatus _mapStatus(String st) {
    switch (st.toUpperCase()) {
      case 'ACTIVE':
        return TripStatus.active;
      case 'COMPLETED':
        return TripStatus.completed;
      case 'DRAFT':
      default:
        return TripStatus.draft;
    }
  }
}
