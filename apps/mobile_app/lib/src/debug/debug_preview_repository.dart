import 'package:twogo_core/twogo_core.dart';
import 'package:twogo_planning/twogo_planning.dart';

/// Fixture preview for `/debug/preview` visual QA (no network).
class DebugPreviewRepository implements PlanningRepository {
  @override
  Future<Result<PlanningPreview>> getPreview(String journeyId) async {
    return Result.success(
      const PlanningPreview(
        id: 'debug-preview',
        status: GuestJourneyStatus.previewReady,
        summary: PlanningPreviewSummary(
          destinations: [
            {
              'name': 'Roma',
              'arrivalDate': '2026-07-25',
              'departureDate': '2026-07-28',
            },
          ],
          startDate: '2026-07-25',
          endDate: '2026-07-28',
          totalDays: 4,
          coverImageUrl:
              'https://images.unsplash.com/photo-1552832230-c0197dd311b5?w=800',
        ),
        policy: PlanningPreviewPolicy(
          visibleDayCount: 1,
          autoPaywallDelaySeconds: 0,
        ),
        visibleDays: [
          PlanningVisibleDay(
            dayNumber: 1,
            date: '2026-07-25',
            destination: 'Roma',
            title: 'Dia 1: Roma',
            activities: [
              PlanningVisibleActivity(
                title: 'Café da manhã',
                category: 'CAFE',
                period: 'Manhã',
                cost: 0,
                order: 1,
                sourceType: 'AI',
              ),
              PlanningVisibleActivity(
                title: 'Piazza Venezia',
                category: 'TOURIST_ATTRACTION',
                period: 'Manhã',
                timeLabel: '08:30 - 10:00',
                cost: 0,
                order: 2,
                latitude: 41.9022,
                longitude: 12.4825,
                imageUrl:
                    'https://images.unsplash.com/photo-1529260830199-42c24126f198?w=200',
                sourceType: 'BASE_ATTRACTION',
              ),
              PlanningVisibleActivity(
                title: 'Fontana di trevi',
                category: 'TOURIST_ATTRACTION',
                period: 'Manhã',
                timeLabel: '10:30 - 11:30',
                cost: 0,
                order: 3,
                latitude: 41.9009,
                longitude: 12.4833,
                imageUrl:
                    'https://images.unsplash.com/photo-1525874684015-58379d421a0e?w=200',
                sourceType: 'BASE_ATTRACTION',
              ),
              PlanningVisibleActivity(
                title: 'Almoço',
                category: 'RESTAURANT',
                period: 'Tarde',
                cost: 0,
                order: 4,
                sourceType: 'AI',
              ),
              PlanningVisibleActivity(
                title: 'Panteão',
                category: 'TOURIST_ATTRACTION',
                period: 'Tarde',
                timeLabel: '13:30 - 15:00',
                cost: 0,
                order: 5,
                latitude: 41.8986,
                longitude: 12.4769,
                imageUrl:
                    'https://images.unsplash.com/photo-1555993539-1732b0258235?w=200',
                sourceType: 'BASE_ATTRACTION',
              ),
              PlanningVisibleActivity(
                title: 'Jantar',
                category: 'RESTAURANT',
                period: 'Noite',
                cost: 0,
                order: 6,
                sourceType: 'AI',
              ),
            ],
          ),
        ],
        lockedDays: [
          PlanningLockedDay(
            dayNumber: 2,
            date: '2026-07-26',
            destination: 'Roma',
            title: 'Dia 2',
          ),
          PlanningLockedDay(
            dayNumber: 3,
            date: '2026-07-27',
            destination: 'Roma',
            title: 'Dia 3',
          ),
          PlanningLockedDay(
            dayNumber: 4,
            date: '2026-07-28',
            destination: 'Roma',
            title: 'Dia 4',
          ),
        ],
        unlockOffer: PlanningUnlockOffer(
          productId: 'prod-full-access',
          code: 'ITINERARY_FULL_ACCESS',
          name: 'Roteiro Completo 2GO',
          price: 19.99,
          currency: 'BRL',
          available: true,
        ),
      ),
    );
  }

  @override
  Future<Result<CreatedGuestJourneyResult>> createJourney({
    int? answersVersion,
    int? initialStep,
  }) =>
      throw UnimplementedError();

  @override
  Future<Result<GuestJourney>> finalizeJourney(String journeyId) =>
      throw UnimplementedError();

  @override
  Future<Result<PlanningGenerationStatus>> getGenerationStatus(
    String journeyId,
  ) =>
      throw UnimplementedError();

  @override
  Future<Result<GuestJourney>> getJourney(String journeyId) =>
      throw UnimplementedError();

  @override
  Future<Result<PlanningGenerationStatus>> startGeneration(String journeyId) =>
      throw UnimplementedError();

  @override
  Future<Result<GuestJourney>> updateJourney({
    required String journeyId,
    int? currentStep,
    List<PlanningDestination>? destinations,
    PlanningTravelers? travelers,
    List<PlanningInterest>? interests,
    PlanningActivityWindow? activityWindow,
    String? budgetLevel,
    String? travelStyle,
  }) =>
      throw UnimplementedError();

  @override
  Future<Result<ClaimJourneyResult>> claimJourney(String journeyId) =>
      throw UnimplementedError();
}
