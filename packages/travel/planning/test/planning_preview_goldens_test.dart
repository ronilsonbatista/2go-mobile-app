import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_core/twogo_core.dart';
import 'package:twogo_planning/twogo_planning.dart';

class FakePlanningRepository implements PlanningRepository {
  @override
  Future<Result<PlanningPreview>> getPreview(String journeyId) async {
    return Result.success(
      const PlanningPreview(
        id: 'journey-golden-123',
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
          autoPaywallDelaySeconds: 0, // 0 to avoid timer in goldens
        ),
        visibleDays: [
          PlanningVisibleDay(
            dayNumber: 1,
            date: '2026-07-25',
            destination: 'Roma',
            title: 'Dia 1: Chegada em Roma',
            description: 'Primeiro dia incrível',
            activities: [
              PlanningVisibleActivity(
                title: 'Coliseu de Roma',
                description: 'Visita guiada pelo monumento',
                category: 'TOURIST_ATTRACTION',
                period: 'Manhã',
                cost: 20.0,
                order: 1,
                location: 'Piazza del Colosseo',
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
          PlanningLockedDay(
            dayNumber: 3,
            date: '2026-07-27',
            destination: 'Roma',
            title: 'Dia 3',
          ),
        ],
        unlockOffer: PlanningUnlockOffer(
          productId: 'prod-full-access',
          code: 'ITINERARY_FULL_ACCESS',
          name: 'Acesso Completo ao Roteiro 2GO',
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

  Widget buildWidget(Size size) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: PlanningPreviewPage(
            journeyId: 'journey-golden-123',
            bloc: bloc,
          ),
        ),
      ),
    );
  }

  testWidgets('planning_preview_loaded_390x844 UI test', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(buildWidget(const Size(390, 844)));
    await tester.runAsync(() async {
      await bloc.stream.firstWhere((s) => s is PlanningPreviewLoadedState);
    });
    await tester.pump();

    expect(find.text('Roma'), findsOneWidget);
    expect(find.text('Dia 1: Chegada em Roma'), findsOneWidget);
    expect(find.text('Coliseu de Roma'), findsOneWidget);
    expect(find.text('Curadoria 2GO'), findsOneWidget);
    expect(find.text('R\$ 19,99'), findsOneWidget);
  });
}
