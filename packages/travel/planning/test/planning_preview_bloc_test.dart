import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_core/twogo_core.dart';
import 'package:twogo_planning/twogo_planning.dart';

class FakePlanningRepository implements PlanningRepository {
  PlanningPreview? mockPreview;
  AppFailure? mockFailure;

  @override
  Future<Result<PlanningPreview>> getPreview(String journeyId) async {
    if (mockFailure != null) {
      return Result.failure(mockFailure!);
    }
    return Result.success(
      mockPreview ??
          const PlanningPreview(
            id: 'journey-123',
            status: GuestJourneyStatus.previewReady,
            summary: PlanningPreviewSummary(
              destinations: [
                {'name': 'Roma', 'arrivalDate': '2026-07-25'}
              ],
              startDate: '2026-07-25',
              endDate: '2026-07-28',
              totalDays: 4,
            ),
            policy: PlanningPreviewPolicy(
              visibleDayCount: 1,
              autoPaywallDelaySeconds: 10,
            ),
            visibleDays: [
              PlanningVisibleDay(
                dayNumber: 1,
                date: '2026-07-25',
                destination: 'Roma',
                title: 'Dia 1: Chegada',
                activities: [
                  PlanningVisibleActivity(
                    title: 'Coliseu',
                    category: 'TOURIST_ATTRACTION',
                    cost: 20.0,
                    order: 1,
                    sourceType: 'BASE_ATTRACTION',
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
            ],
            unlockOffer: PlanningUnlockOffer(
              productId: 'prod-full-access',
              code: 'ITINERARY_FULL_ACCESS',
              name: 'Acesso Completo',
              price: 19.99,
              currency: 'BRL',
              available: true,
            ),
          ),
    );
  }

  @override
  Future<Result<CreatedGuestJourneyResult>> createJourney(
      {int? answersVersion, int? initialStep}) async =>
      throw UnimplementedError();

  @override
  Future<Result<GuestJourney>> finalizeJourney(String journeyId) async =>
      throw UnimplementedError();

  @override
  Future<Result<PlanningGenerationStatus>> getGenerationStatus(
          String journeyId) async =>
      throw UnimplementedError();

  @override
  Future<Result<GuestJourney>> getJourney(String journeyId) async =>
      throw UnimplementedError();

  @override
  Future<Result<PlanningGenerationStatus>> startGeneration(
          String journeyId) async =>
      throw UnimplementedError();

  @override
  Future<Result<GuestJourney>> updateJourney(
          {required String journeyId,
          int? currentStep,
          List<PlanningDestination>? destinations,
          PlanningTravelers? travelers,
          List<PlanningInterest>? interests,
          PlanningActivityWindow? activityWindow,
          String? budgetLevel,
          String? travelStyle}) async =>
      throw UnimplementedError();
}

void main() {
  late FakePlanningRepository repository;
  late GetPlanningPreviewUseCase getPreviewUseCase;
  late PlanningPreviewBloc bloc;

  setUp(() {
    repository = FakePlanningRepository();
    getPreviewUseCase = GetPlanningPreviewUseCase(repository);
    bloc = PlanningPreviewBloc(getPreviewUseCase: getPreviewUseCase);
  });

  tearDown(() {
    bloc.close();
  });

  group('PlanningPreviewBloc Tests', () {
    test('FetchPlanningPreviewEvent emits Loading then Loaded state', () async {
      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<PlanningPreviewLoadingState>(),
          isA<PlanningPreviewLoadedState>().having(
            (s) => s.preview.id,
            'journey id',
            'journey-123',
          ),
        ]),
      );

      bloc.add(const FetchPlanningPreviewEvent(journeyId: 'journey-123'));
      await expectation;
    });

    test(
        'SelectPreviewDayEvent on locked day emits OpenPaywallEvent with LOCKED_DAY source',
        () async {
      bloc.add(const FetchPlanningPreviewEvent(journeyId: 'journey-123'));
      await bloc.stream.firstWhere((s) => s is PlanningPreviewLoadedState);

      final expectation = expectLater(
        bloc.stream,
        emits(
          isA<PlanningPreviewLoadedState>()
              .having((s) => s.isPaywallOpen, 'paywall open', true)
              .having((s) => s.paywallSource, 'source', 'LOCKED_DAY'),
        ),
      );

      bloc.add(const SelectPreviewDayEvent(dayNumber: 2));
      await expectation;
    });

    test('RequestUnlockEvent emits PlanningPreviewUnlockRequestedState',
        () async {
      bloc.add(const FetchPlanningPreviewEvent(journeyId: 'journey-123'));
      await bloc.stream.firstWhere((s) => s is PlanningPreviewLoadedState);

      final expectation = expectLater(
        bloc.stream,
        emits(
          isA<PlanningPreviewUnlockRequestedState>()
              .having((s) => s.journeyId, 'journey id', 'journey-123')
              .having((s) => s.productId, 'product id', 'prod-full-access')
              .having((s) => s.price, 'price', 19.99),
        ),
      );

      bloc.add(const RequestUnlockEvent());
      await expectation;
    });
  });
}
