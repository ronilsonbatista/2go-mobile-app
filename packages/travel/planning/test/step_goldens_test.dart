import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_design_system/design_system.dart';
import 'package:twogo_planning/twogo_planning.dart';
import 'planning_repository_test.dart';

void main() {
  late FakePlanningApiClient apiClient;
  late FakeGuestJourneyCredentialStorage credentialStorage;
  late InMemoryPlanningDraftStorage draftStorage;
  late PlanningRepositoryImpl repository;

  late CreatePlanningJourneyUseCase createUseCase;
  late RestorePlanningJourneyUseCase restoreUseCase;
  late SavePlanningProgressUseCase saveUseCase;
  late FinalizePlanningJourneyUseCase finalizeUseCase;

  setUp(() {
    apiClient = FakePlanningApiClient();
    credentialStorage = FakeGuestJourneyCredentialStorage();
    draftStorage = InMemoryPlanningDraftStorage();
    repository = PlanningRepositoryImpl(
      apiClient: apiClient,
      credentialStorage: credentialStorage,
    );

    createUseCase = CreatePlanningJourneyUseCase(
      repository: repository,
      credentialStorage: credentialStorage,
      draftStorage: draftStorage,
    );

    restoreUseCase = RestorePlanningJourneyUseCase(
      repository: repository,
      credentialStorage: credentialStorage,
      draftStorage: draftStorage,
    );

    saveUseCase = SavePlanningProgressUseCase(
      repository: repository,
      draftStorage: draftStorage,
    );

    finalizeUseCase = FinalizePlanningJourneyUseCase(
      repository: repository,
      draftStorage: draftStorage,
    );
  });

  PlanningWizardBloc createBloc({
    int initialStep = 1,
    List<PlanningDestination>? destinations,
    PlanningTravelers? travelers,
    List<PlanningInterest>? interests,
    PlanningActivityWindow? activityWindow,
    String? budgetLevel,
  }) {
    const defaultDestination = PlanningDestination(
      name: '',
      arrivalDate: '',
      arrivalTime: '',
      departureDate: '',
      departureTime: '',
      order: 0,
    );

    final resolvedDestinations = destinations ?? const [defaultDestination];
    final resolvedTravelers = travelers ?? const PlanningTravelers(adults: 1);
    final resolvedInterests = interests ?? const [];
    final resolvedWindow =
        activityWindow ??
        const PlanningActivityWindow(start: '09:00', end: '18:30');

    final dummyJourney = GuestJourney(
      id: 'journey_test',
      status: GuestJourneyStatus.collecting,
      answersVersion: 1,
      currentStep: initialStep,
      destinations: resolvedDestinations,
      travelers: resolvedTravelers,
      interests: resolvedInterests,
      activityWindow: resolvedWindow,
      budgetLevel: budgetLevel,
      expiresAt: DateTime.now().add(const Duration(days: 7)),
    );

    return PlanningWizardBloc(
      createUseCase: createUseCase,
      restoreUseCase: restoreUseCase,
      saveUseCase: saveUseCase,
      finalizeUseCase: finalizeUseCase,
      draftStorage: draftStorage,
      initialState: PlanningWizardState(
        status: PlanningWizardStatus.editing,
        journey: dummyJourney,
        currentStep: initialStep,
        destinations: resolvedDestinations,
        travelers: resolvedTravelers,
        interests: resolvedInterests,
        activityWindow: resolvedWindow,
        budgetLevel: budgetLevel,
      ),
    );
  }

  Widget buildWizardWidget(PlanningWizardBloc bloc) {
    return MaterialApp(
      theme: TwoGoTheme.light,
      home: PlanningWizardPage(bloc: bloc),
      debugShowCheckedModeBanner: false,
    );
  }

  group('Wizard Steps 1-6 Golden & Viewport Responsive Tests', () {
    testWidgets('planning_where_empty_390x844 renders cleanly', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final bloc = createBloc(initialStep: 1);
      await tester.pumpWidget(buildWizardWidget(bloc));
      await tester.pumpAndSettle();

      expect(find.text('Para onde você quer viajar?'), findsWidgets);
      expect(find.text('Destino 1'), findsOneWidget);
      expect(find.text('Adicionar outro destino'), findsOneWidget);
    });

    testWidgets(
      'planning_travelers_filled_390x844 renders updated travelers counts',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final bloc = createBloc(
          initialStep: 2,
          travelers: const PlanningTravelers(adults: 3, children: 2, elders: 1),
        );
        await tester.pumpWidget(buildWizardWidget(bloc));
        await tester.pumpAndSettle();

        expect(find.text('3'), findsOneWidget);
        expect(find.text('2'), findsOneWidget);
        expect(find.text('1'), findsOneWidget);
      },
    );

    testWidgets('planning_interests_empty_390x844 renders interests step', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final bloc = createBloc(initialStep: 3);
      await tester.pumpWidget(buildWizardWidget(bloc));
      await tester.pumpAndSettle();

      expect(find.text('O que você mais gosta de fazer?'), findsWidgets);
      expect(find.text('Arte'), findsOneWidget);
      expect(find.text('Gastronomia'), findsOneWidget);
    });

    testWidgets(
      'planning_interests_selected_390x844 renders selected interests',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final bloc = createBloc(
          initialStep: 3,
          interests: const [PlanningInterest.art, PlanningInterest.gastronomy],
        );
        await tester.pumpWidget(buildWizardWidget(bloc));
        await tester.pumpAndSettle();

        expect(find.byType(InterestsStepContent), findsOneWidget);
        expect(find.text('Arte'), findsOneWidget);
        expect(find.text('Gastronomia'), findsOneWidget);
        expect(find.byIcon(Icons.check_circle), findsNWidgets(2));
      },
    );

    testWidgets('planning_activity_hours_390x844 renders time window pickers', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final bloc = createBloc(
        initialStep: 4,
        activityWindow: const PlanningActivityWindow(
          start: '09:00',
          end: '18:30',
        ),
      );
      await tester.pumpWidget(buildWizardWidget(bloc));
      await tester.pumpAndSettle();

      expect(find.text('Qual o seu ritmo diário?'), findsWidgets);
      expect(find.text('09:00'), findsOneWidget);
      expect(find.text('18:30'), findsOneWidget);
    });

    testWidgets(
      'planning_budget_selected_390x844 renders selected budget tier',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final bloc = createBloc(initialStep: 5, budgetLevel: 'HIGH');
        await tester.pumpWidget(buildWizardWidget(bloc));
        await tester.pumpAndSettle();

        expect(find.text('Qual o perfil financeiro da viagem?'), findsWidgets);
        expect(find.text('Econômica'), findsOneWidget);
        expect(find.text('\$\$\$'), findsOneWidget);
      },
    );

    testWidgets(
      'planning_review_390x844 renders complete questionnaire summary',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final bloc = createBloc(
          initialStep: 6,
          destinations: const [
            PlanningDestination(
              providerPlaceId: 'place_paris',
              name: 'Paris, França',
              arrivalDate: '2026-09-01',
              arrivalTime: '09:00',
              departureDate: '2026-09-05',
              departureTime: '18:00',
              order: 0,
            ),
          ],
          travelers: const PlanningTravelers(adults: 2, children: 1, elders: 0),
          interests: const [PlanningInterest.art, PlanningInterest.gastronomy],
          activityWindow: const PlanningActivityWindow(
            start: '09:00',
            end: '19:00',
          ),
          budgetLevel: 'HIGH',
        );

        await tester.pumpWidget(buildWizardWidget(bloc));
        await tester.pumpAndSettle();

        expect(find.text('Revise seu roteiro'), findsWidgets);
        expect(find.text('Paris, França'), findsOneWidget);
      },
    );

    testWidgets(
      'Review Step 6 renders scrollable without overflow on 360x800, 390x844 and 412x915 viewports',
      (WidgetTester tester) async {
        for (final size in [
          const Size(360, 800),
          const Size(390, 844),
          const Size(412, 915),
        ]) {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;

          final bloc = createBloc(initialStep: 6);
          await tester.pumpWidget(buildWizardWidget(bloc));
          await tester.pumpAndSettle();

          expect(find.byType(PlanningWizardScaffold), findsOneWidget);
          expect(tester.takeException(), isNull);
        }
        tester.view.resetPhysicalSize();
      },
    );
  });
}
