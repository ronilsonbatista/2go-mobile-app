import 'package:twogo_planning/twogo_planning.dart';

import 'entities/itinerary_item_entity.dart';
import 'entities/trip_day_entity.dart';
import 'entities/trip_entity.dart';

/// Maps an owned/paid [TripEntity] into a [PlanningPreview] shell so the
/// Day-1 preview widgets can render the paid itinerary (all days visible).
PlanningPreview tripToPlanningPreview(TripEntity trip) {
  final days = [...trip.days]
    ..sort((a, b) => a.dayNumber.compareTo(b.dayNumber));
  final visible = days.map(_mapDay).toList(growable: false);
  final start = trip.arrivalDateTime ?? trip.startDate;
  final end = trip.departureDateTime ?? trip.endDate;

  return PlanningPreview(
    id: trip.id,
    status: GuestJourneyStatus.paid,
    summary: PlanningPreviewSummary(
      destinations: [
        {
          'name': trip.destination,
          if (trip.coverImage != null && trip.coverImage!.trim().isNotEmpty)
            'coverImage': trip.coverImage,
        },
      ],
      startDate: start?.toIso8601String(),
      endDate: end?.toIso8601String(),
      totalDays: days.isEmpty ? 1 : days.length,
      coverImageUrl: trip.coverImage,
    ),
    policy: PlanningPreviewPolicy(
      visibleDayCount: days.isEmpty ? 1 : days.length,
      autoPaywallDelaySeconds: 0,
    ),
    visibleDays: visible,
    lockedDays: const [],
    unlockOffer: const PlanningUnlockOffer(
      code: 'PAID',
      name: 'Roteiro completo',
      price: 0,
      amount: 0,
      currency: 'BRL',
      days: 0,
      tier: '',
      available: false,
    ),
  );
}

PlanningVisibleDay _mapDay(TripDayEntity day) {
  final items = [...day.items]..sort((a, b) => a.order.compareTo(b.order));
  return PlanningVisibleDay(
    dayNumber: day.dayNumber,
    date: day.date?.toIso8601String().split('T').first,
    destination: '',
    title: day.title?.trim().isNotEmpty == true
        ? day.title!.trim()
        : 'Dia ${day.dayNumber}',
    description: day.description,
    activities: items.map(_mapItem).toList(growable: false),
  );
}

PlanningVisibleActivity _mapItem(ItineraryItemEntity item) {
  return PlanningVisibleActivity(
    title: item.title,
    description: item.description,
    category: _categoryString(item.category),
    period: item.period,
    timeLabel: item.timeLabel,
    duration: item.duration,
    cost: item.cost ?? 0,
    order: item.order,
    location: item.location,
    latitude: item.latitude,
    longitude: item.longitude,
    providerPlaceId: item.providerPlaceId,
    imageUrl: null,
    reservationUrl: item.externalLink,
    ticketUrl: null,
    sourceType: 'TRIP_ITEM',
    sourceId: item.id,
  );
}

String _categoryString(ItineraryCategory category) {
  switch (category) {
    case ItineraryCategory.cafe:
      return 'CAFE';
    case ItineraryCategory.restaurant:
      return 'RESTAURANT';
    case ItineraryCategory.bar:
      return 'BAR';
    case ItineraryCategory.transport:
      return 'TRANSPORT';
    case ItineraryCategory.museum:
      return 'MUSEUM';
    case ItineraryCategory.beach:
      return 'BEACH';
    case ItineraryCategory.park:
      return 'PARK';
    case ItineraryCategory.shopping:
      return 'SHOPPING';
    case ItineraryCategory.experience:
      return 'EXPERIENCE';
    case ItineraryCategory.event:
      return 'EVENT';
    case ItineraryCategory.nightlife:
      return 'NIGHTLIFE';
    case ItineraryCategory.freeActivity:
      return 'FREE_ACTIVITY';
    case ItineraryCategory.paidActivity:
      return 'PAID_ACTIVITY';
    case ItineraryCategory.touristAttraction:
      return 'ATTRACTION';
  }
}

/// Finds the itinerary item for a mapped preview activity (`sourceId`).
ItineraryItemEntity? findTripItemForActivity(
  TripEntity trip,
  PlanningVisibleActivity activity,
) {
  final id = activity.sourceId?.trim();
  if (id == null || id.isEmpty) return null;
  for (final day in trip.days) {
    for (final item in day.items) {
      if (item.id == id) return item;
    }
  }
  return null;
}

TripDayEntity? findTripDay(
  TripEntity trip,
  int dayNumber,
) {
  for (final day in trip.days) {
    if (day.dayNumber == dayNumber) return day;
  }
  return null;
}
