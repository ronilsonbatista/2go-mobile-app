import '../../domain/entities/trip_entity.dart';
import 'trip_accommodation_dto.dart';
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
  final String? arrivalDateTime;
  final String? departureDateTime;
  final int? usedSwapsCount;
  final int? allowedSwapsCount;
  final TripAccommodationDto? accommodation;
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
    this.arrivalDateTime,
    this.departureDateTime,
    this.usedSwapsCount,
    this.allowedSwapsCount,
    this.accommodation,
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
      arrivalDateTime: json['arrivalDateTime'] as String?,
      departureDateTime: json['departureDateTime'] as String?,
      usedSwapsCount: _readCount(json['usedSwapsCount']),
      allowedSwapsCount: _readCount(json['allowedSwapsCount']),
      accommodation: json['accommodation'] is Map
          ? TripAccommodationDto.fromJson(
              Map<String, dynamic>.from(json['accommodation'] as Map),
            )
          : null,
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
      'arrivalDateTime': arrivalDateTime,
      'departureDateTime': departureDateTime,
      'usedSwapsCount': usedSwapsCount,
      'allowedSwapsCount': allowedSwapsCount,
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
      arrivalDateTime: arrivalDateTime != null
          ? DateTime.tryParse(arrivalDateTime!)
          : null,
      departureDateTime: departureDateTime != null
          ? DateTime.tryParse(departureDateTime!)
          : null,
      usedSwapsCount: usedSwapsCount,
      allowedSwapsCount: allowedSwapsCount,
      accommodation: accommodation?.toEntity(),
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

int? _readCount(dynamic raw) {
  if (raw is int) return raw;
  if (raw is num) return raw.toInt();
  return null;
}
