import 'trip_day_entity.dart';

enum TripStatus { draft, active, completed }

class TripEntity {
  final String id;
  final String userId;
  final String title;
  final String destination;
  final String? coverImage;
  final DateTime? startDate;
  final DateTime? endDate;
  final TripStatus status;
  final Map<String, dynamic>? preferences;
  final DateTime? premiumUnlockedAt;
  final List<TripDayEntity> days;

  const TripEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.destination,
    this.coverImage,
    this.startDate,
    this.endDate,
    this.status = TripStatus.draft,
    this.preferences,
    this.premiumUnlockedAt,
    this.days = const [],
  });

  bool get isPremium => premiumUnlockedAt != null;

  TripEntity copyWith({
    String? title,
    String? destination,
    String? coverImage,
    DateTime? startDate,
    DateTime? endDate,
    TripStatus? status,
    Map<String, dynamic>? preferences,
    DateTime? premiumUnlockedAt,
    List<TripDayEntity>? days,
  }) {
    return TripEntity(
      id: id,
      userId: userId,
      title: title ?? this.title,
      destination: destination ?? this.destination,
      coverImage: coverImage ?? this.coverImage,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      preferences: preferences ?? this.preferences,
      premiumUnlockedAt: premiumUnlockedAt ?? this.premiumUnlockedAt,
      days: days ?? this.days,
    );
  }
}
