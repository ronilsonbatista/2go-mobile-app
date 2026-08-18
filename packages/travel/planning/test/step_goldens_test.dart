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

  PlanningWizardBloc createBloc() {
    return PlanningWizardBloc(
      createUseCase: createUseCase,
      restoreUseCase: restoreUseCase,
      saveUseCase: saveUseCase,
      finalizeUseCase: finalizeUseCase,
      draftStorage: draftStorage,
    );
  }

  Widget buildWizardWidget(PlanningWizardBloc bloc) {
    return MaterialApp(
      theme: TwoGoTheme.light,
      home: PlanningWizardPage(bloc: bloc),
      debugShowCheckedModeBanner: false,
    );
  }

  group('Step 1 & Step 2 Golden & Viewport Responsive Tests', () {
    testWidgets('planning_where_empty_390x844 renders cleanly', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final bloc = createBloc();
      bloc.add(const InitializeWizardEvent());

      await tester.pumpWidget(buildWizardWidget(bloc));
      await tester.pumpAndSettle();

      expect(find.text('Para onde você quer viajar?'), findsOneWidget);
      expect(find.text('Destino 1'), findsOneWidget);
      expect(find.text('Adicionar outro destino'), findsOneWidget);
    });

    testWidgets(
      'planning_where_destination_selected_390x844 renders selected destination',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final bloc = createBloc();
        bloc.add(const InitializeWizardEvent());
        await tester.pumpWidget(buildWizardWidget(bloc));
        await tester.pumpAndSettle();

        bloc.add(
          const UpdateDestinationAtEvent(
            0,
            PlanningDestination(
              providerPlaceId: 'place_paris_001',
              name: 'Paris, França',
              arrivalDate: '2026-09-01',
              arrivalTime: '09:00',
              departureDate: '2026-09-05',
              departureTime: '18:00',
              order: 0,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Paris, França'), findsOneWidget);
        expect(find.text('01/09/2026'), findsOneWidget);
        expect(find.text('05/09/2026'), findsOneWidget);
      },
    );

    testWidgets(
      'planning_where_multiple_destinations_390x844 renders multiple destination cards',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final bloc = createBloc();
        bloc.add(const InitializeWizardEvent());
        await tester.pumpWidget(buildWizardWidget(bloc));
        await tester.pumpAndSettle();

        bloc.add(const AddDestinationEvent());
        await tester.pumpAndSettle();

        expect(find.text('Destino 1'), findsOneWidget);
        expect(find.text('Destino 2'), findsOneWidget);
      },
    );

    testWidgets(
      'planning_travelers_default_390x844 renders default travelers counters',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final bloc = createBloc();
        bloc.add(const InitializeWizardEvent());
        await tester.pumpWidget(buildWizardWidget(bloc));
        await tester.pumpAndSettle();

        bloc.add(const GoToStepEvent(2));
        await tester.pumpAndSettle();

        expect(find.text('Quem vai?'), findsOneWidget);
        expect(find.text('Adultos'), findsOneWidget);
        expect(find.text('Crianças'), findsOneWidget);
        expect(find.text('Idosos'), findsOneWidget);
      },
    );

    testWidgets(
      'planning_travelers_filled_390x844 renders updated travelers counts',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final bloc = createBloc();
        bloc.add(const InitializeWizardEvent());
        await tester.pumpWidget(buildWizardWidget(bloc));
        await tester.pumpAndSettle();

        bloc.add(const GoToStepEvent(2));
        await tester.pumpAndSettle();

        bloc.add(
          const UpdateTravelersEvent(
            PlanningTravelers(adults: 3, children: 2, elders: 1),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('3'), findsOneWidget);
        expect(find.text('2'), findsOneWidget);
        expect(find.text('1'), findsOneWidget);
      },
    );

    testWidgets(
      'Step 1 and Step 2 render without overflow on 360x800 and 412x915 viewports',
      (WidgetTester tester) async {
        for (final size in [const Size(360, 800), const Size(412, 915)]) {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;

          final bloc = createBloc();
          bloc.add(const InitializeWizardEvent());
          await tester.pumpWidget(buildWizardWidget(bloc));
          await tester.pumpAndSettle();

          expect(find.byType(PlanningWizardScaffold), findsOneWidget);
          expect(tester.takeException(), isNull);

          bloc.add(const GoToStepEvent(2));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
        tester.view.resetPhysicalSize();
      },
    );
  });
}
