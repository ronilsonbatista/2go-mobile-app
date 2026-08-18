import 'package:flutter_test/flutter_test.dart';
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
  late PlanningWizardBloc bloc;

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

    bloc = PlanningWizardBloc(
      createUseCase: createUseCase,
      restoreUseCase: restoreUseCase,
      saveUseCase: saveUseCase,
      finalizeUseCase: finalizeUseCase,
      draftStorage: draftStorage,
    );
  });

  group('PlanningWizardBloc Foundation Tests', () {
    test('initial state has default currentStep = 1 and totalSteps = 6', () {
      expect(bloc.state.currentStep, 1);
      expect(bloc.state.totalSteps, 6);
      expect(bloc.state.status, PlanningWizardStatus.initial);
    });

    test(
      'InitializeWizardEvent creates new session when no active journey',
      () async {
        bloc.add(const InitializeWizardEvent());
        await expectLater(
          bloc.stream,
          emitsInOrder([
            isA<PlanningWizardState>().having(
              (s) => s.status,
              'status',
              PlanningWizardStatus.loading,
            ),
            isA<PlanningWizardState>()
                .having((s) => s.status, 'status', PlanningWizardStatus.editing)
                .having((s) => s.currentStep, 'currentStep', 1),
          ]),
        );
      },
    );

    test(
      'NextStepEvent advances step and PreviousStepEvent decrements step',
      () async {
        bloc.add(const InitializeWizardEvent());
        await bloc.stream.firstWhere(
          (s) => s.status == PlanningWizardStatus.editing,
        );

        bloc.add(const NextStepEvent());
        await bloc.stream.firstWhere((s) => s.currentStep == 2);
        expect(bloc.state.currentStep, 2);

        bloc.add(const PreviousStepEvent());
        await bloc.stream.firstWhere((s) => s.currentStep == 1);
        expect(bloc.state.currentStep, 1);
      },
    );

    test('PreviousStepEvent at step 1 emits exit status', () async {
      bloc.add(const InitializeWizardEvent());
      await bloc.stream.firstWhere(
        (s) => s.status == PlanningWizardStatus.editing,
      );

      bloc.add(const PreviousStepEvent());
      await bloc.stream.firstWhere(
        (s) => s.status == PlanningWizardStatus.exit,
      );
      expect(bloc.state.status, PlanningWizardStatus.exit);
    });

    test('GoToStepEvent jumps to target step', () async {
      bloc.add(const InitializeWizardEvent());
      await bloc.stream.firstWhere(
        (s) => s.status == PlanningWizardStatus.editing,
      );

      bloc.add(const GoToStepEvent(5));
      await bloc.stream.firstWhere((s) => s.currentStep == 5);
      expect(bloc.state.currentStep, 5);
    });
  });
}
