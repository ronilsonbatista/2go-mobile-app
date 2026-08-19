import 'package:app_roteiros_api/app_roteiros_api.dart';
import '../domain/models/guest_journey.dart';
import '../domain/models/guest_journey_status.dart';
import '../domain/models/planning_activity_window.dart';
import '../domain/models/planning_destination.dart';
import '../domain/models/planning_generation_status.dart';
import '../domain/models/planning_interest.dart';
import '../domain/models/planning_preview.dart';
import '../domain/models/planning_travelers.dart';

class PlanningMapper {
  static GuestJourney toDomain(PlanningSessionResponseDto dto) {
    return GuestJourney(
      id: dto.id,
      status: GuestJourneyStatus.fromRaw(dto.status),
      answersVersion: dto.answersVersion,
      currentStep: dto.currentStep,
      destinations: dto.destinations?.map(destinationToDomain).toList(),
      travelers: dto.travelers != null
          ? travelersToDomain(dto.travelers!)
          : null,
      interests: dto.interests?.map(PlanningInterest.fromRaw).toList(),
      activityWindow: dto.activityHours != null
          ? activityWindowToDomain(dto.activityHours!)
          : null,
      budgetLevel: dto.budgetLevel,
      travelStyle: dto.travelStyle,
      expiresAt: DateTime.tryParse(dto.expiresAt) ?? DateTime.now(),
    );
  }

  static PlanningGenerationStatus toGenerationStatusDomain(
    GenerationStatusResponseDto dto,
  ) {
    return PlanningGenerationStatus(
      journeyId: dto.id,
      status: GuestJourneyStatus.fromRaw(dto.status),
      generationStartedAt: dto.generationStartedAt != null
          ? DateTime.tryParse(dto.generationStartedAt!)
          : null,
      generationCompletedAt: dto.generationCompletedAt != null
          ? DateTime.tryParse(dto.generationCompletedAt!)
          : null,
      generationFailedAt: dto.generationFailedAt != null
          ? DateTime.tryParse(dto.generationFailedAt!)
          : null,
      generationErrorCode: dto.generationErrorCode,
    );
  }

  static PlanningPreview toPreviewDomain(PlanningPreviewResponseDto dto) {
    return PlanningPreview(
      id: dto.id,
      status: GuestJourneyStatus.fromRaw(dto.status),
      summary: PlanningPreviewSummary(
        destinations: dto.summary.destinations,
        startDate: dto.summary.startDate,
        endDate: dto.summary.endDate,
        totalDays: dto.summary.totalDays,
        coverImageUrl: dto.summary.coverImageUrl,
      ),
      policy: PlanningPreviewPolicy(
        visibleDayCount: dto.previewPolicy.visibleDayCount,
        autoPaywallDelaySeconds: dto.previewPolicy.autoPaywallDelaySeconds,
      ),
      visibleDays: dto.visibleDays
          .map(
            (day) => PlanningVisibleDay(
              dayNumber: day.dayNumber,
              date: day.date,
              destination: day.destination,
              title: day.title,
              description: day.description,
              activities: day.activities
                  .map(
                    (act) => PlanningVisibleActivity(
                      title: act.title,
                      description: act.description,
                      category: act.category,
                      period: act.period,
                      cost: act.cost,
                      order: act.order,
                      location: act.location,
                      latitude: act.latitude,
                      longitude: act.longitude,
                      providerPlaceId: act.providerPlaceId,
                      imageUrl: act.imageUrl,
                      reservationUrl: act.reservationUrl,
                      ticketUrl: act.ticketUrl,
                      sourceType: act.sourceType,
                      sourceId: act.sourceId,
                    ),
                  )
                  .toList(),
            ),
          )
          .toList(),
      lockedDays: dto.lockedDays
          .map(
            (day) => PlanningLockedDay(
              dayNumber: day.dayNumber,
              date: day.date,
              destination: day.destination,
              title: day.title,
              locked: day.locked,
            ),
          )
          .toList(),
      unlockOffer: PlanningUnlockOffer(
        productId: dto.unlockOffer.productId,
        code: dto.unlockOffer.code,
        name: dto.unlockOffer.name,
        price: dto.unlockOffer.price,
        currency: dto.unlockOffer.currency,
        available: dto.unlockOffer.available,
      ),
    );
  }

  static CreatedGuestJourneyResult toCreatedResult(
    CreatePlanningSessionResponseDto dto,
  ) {
    return CreatedGuestJourneyResult(
      journey: toDomain(dto),
      guestToken: dto.guestToken,
    );
  }

  static PlanningDestination destinationToDomain(PlanningDestinationDto dto) {
    return PlanningDestination(
      providerPlaceId: dto.providerPlaceId,
      name: dto.name,
      city: dto.city,
      country: dto.country,
      coverImage: dto.coverImage,
      arrivalDate: dto.arrivalDate,
      arrivalTime: dto.arrivalTime,
      departureDate: dto.departureDate,
      departureTime: dto.departureTime,
      order: dto.order ?? 1,
    );
  }

  static PlanningDestinationDto destinationToDto(PlanningDestination model) {
    return PlanningDestinationDto(
      providerPlaceId: model.providerPlaceId,
      name: model.name,
      city: model.city,
      country: model.country,
      coverImage: model.coverImage,
      arrivalDate: model.arrivalDate,
      arrivalTime: model.arrivalTime,
      departureDate: model.departureDate,
      departureTime: model.departureTime,
      order: model.order,
    );
  }

  static PlanningTravelers travelersToDomain(PlanningTravelersDto dto) {
    return PlanningTravelers(
      adults: dto.adults,
      children: dto.children,
      elders: dto.elders,
    );
  }

  static PlanningTravelersDto travelersToDto(PlanningTravelers model) {
    return PlanningTravelersDto(
      adults: model.adults,
      children: model.children,
      elders: model.elders,
    );
  }

  static PlanningActivityWindow activityWindowToDomain(
    PlanningActivityWindowDto dto,
  ) {
    return PlanningActivityWindow(start: dto.startTime, end: dto.endTime);
  }

  static PlanningActivityWindowDto activityWindowToDto(
    PlanningActivityWindow model,
  ) {
    return PlanningActivityWindowDto(
      startTime: model.start,
      endTime: model.end,
    );
  }
}
