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

  group('Planning Wizard Structural Golden & Responsive Tests', () {
    testWidgets('Step 1 renders cleanly on 390x844 viewport', (
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
      expect(find.text('1 de 6'), findsOneWidget);
      expect(find.text('Continuar'), findsOneWidget);
    });

    testWidgets('Step 3 (Middle) renders cleanly on 390x844 viewport', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final bloc = createBloc();
      bloc.add(const InitializeWizardEvent());

      await tester.pumpWidget(buildWizardWidget(bloc));
      await tester.pumpAndSettle();

      bloc.add(const GoToStepEvent(3));
      await tester.pumpAndSettle();

      expect(
        find.text('Selecione os interesses que combinam com você.'),
        findsOneWidget,
      );
      expect(find.text('3 de 6'), findsOneWidget);
    });

    testWidgets(
      'Step 1 renders without overflow on 360x800 and 412x915 viewports',
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
        }
        tester.view.resetPhysicalSize();
      },
    );
  });
}
