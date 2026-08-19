import 'package:equatable/equatable.dart';
import 'guest_journey_status.dart';

class PlanningPreviewSummary extends Equatable {
  final List<dynamic> destinations;
  final String? startDate;
  final String? endDate;
  final int totalDays;
  final String? coverImageUrl;

  const PlanningPreviewSummary({
    required this.destinations,
    this.startDate,
    this.endDate,
    required this.totalDays,
    this.coverImageUrl,
  });

  @override
  List<Object?> get props => [
        destinations,
        startDate,
        endDate,
        totalDays,
        coverImageUrl,
      ];
}

class PlanningPreviewPolicy extends Equatable {
  final int visibleDayCount;
  final int autoPaywallDelaySeconds;

  const PlanningPreviewPolicy({
    required this.visibleDayCount,
    required this.autoPaywallDelaySeconds,
  });

  @override
  List<Object?> get props => [visibleDayCount, autoPaywallDelaySeconds];
}

class PlanningVisibleActivity extends Equatable {
  final String title;
  final String? description;
  final String category;
  final String? period;
  final double cost;
  final int order;
  final String? location;
  final double? latitude;
  final double? longitude;
  final String? providerPlaceId;
  final String? imageUrl;
  final String? reservationUrl;
  final String? ticketUrl;
  final String sourceType;
  final String? sourceId;

  const PlanningVisibleActivity({
    required this.title,
    this.description,
    required this.category,
    this.period,
    required this.cost,
    required this.order,
    this.location,
    this.latitude,
    this.longitude,
    this.providerPlaceId,
    this.imageUrl,
    this.reservationUrl,
    this.ticketUrl,
    required this.sourceType,
    this.sourceId,
  });

  bool get isCurated =>
      sourceType == 'BASE_TRIP' ||
      sourceType == 'BASE_ATTRACTION' ||
      sourceType == 'BASE_RESTAURANT';

  @override
  List<Object?> get props => [
        title,
        description,
        category,
        period,
        cost,
        order,
        location,
        latitude,
        longitude,
        providerPlaceId,
        imageUrl,
        reservationUrl,
        ticketUrl,
        sourceType,
        sourceId,
      ];
}

class PlanningVisibleDay extends Equatable {
  final int dayNumber;
  final String? date;
  final String destination;
  final String title;
  final String? description;
  final List<PlanningVisibleActivity> activities;

  const PlanningVisibleDay({
    required this.dayNumber,
    this.date,
    required this.destination,
    required this.title,
    this.description,
    required this.activities,
  });

  @override
  List<Object?> get props => [
        dayNumber,
        date,
        destination,
        title,
        description,
        activities,
      ];
}

class PlanningLockedDay extends Equatable {
  final int dayNumber;
  final String? date;
  final String destination;
  final String title;
  final bool locked;

  const PlanningLockedDay({
    required this.dayNumber,
    this.date,
    required this.destination,
    required this.title,
    this.locked = true,
  });

  @override
  List<Object?> get props => [dayNumber, date, destination, title, locked];
}

class PlanningUnlockOffer extends Equatable {
  final String? productId;
  final String code;
  final String name;
  final double price;
  final String currency;
  final bool available;

  const PlanningUnlockOffer({
    this.productId,
    required this.code,
    required this.name,
    required this.price,
    required this.currency,
    required this.available,
  });

  @override
  List<Object?> get props => [
        productId,
        code,
        name,
        price,
        currency,
        available,
      ];
}

class PlanningPreview extends Equatable {
  final String id;
  final GuestJourneyStatus status;
  final PlanningPreviewSummary summary;
  final PlanningPreviewPolicy policy;
  final List<PlanningVisibleDay> visibleDays;
  final List<PlanningLockedDay> lockedDays;
  final PlanningUnlockOffer unlockOffer;

  const PlanningPreview({
    required this.id,
    required this.status,
    required this.summary,
    required this.policy,
    required this.visibleDays,
    required this.lockedDays,
    required this.unlockOffer,
  });

  @override
  List<Object?> get props => [
        id,
        status,
        summary,
        policy,
        visibleDays,
        lockedDays,
        unlockOffer,
      ];
}
