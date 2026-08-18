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

  group('Step 2 — Travelers Validation & Logic Tests', () {
    test(
      'default travelers has 1 adult, 0 children, 0 elders and is valid',
      () {
        expect(bloc.state.travelers.adults, 1);
        expect(bloc.state.travelers.children, 0);
        expect(bloc.state.travelers.elders, 0);
        expect(bloc.state.travelers.total, 1);
        expect(bloc.state.isStep2Valid, isTrue);
      },
    );

    test('updates travelers count cleanly', () async {
      bloc.add(
        const UpdateTravelersEvent(
          PlanningTravelers(adults: 2, children: 1, elders: 1),
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.travelers.adults, 2);
      expect(bloc.state.travelers.children, 1);
      expect(bloc.state.travelers.elders, 1);
      expect(bloc.state.travelers.total, 4);
      expect(bloc.state.isStep2Valid, isTrue);
    });

    test('invalidates when total travelers count is 0', () async {
      bloc.add(
        const UpdateTravelersEvent(
          PlanningTravelers(adults: 0, children: 0, elders: 0),
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.isStep2Valid, isFalse);
    });
  });
}
