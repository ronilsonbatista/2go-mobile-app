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
      'InitializeWizardEvent starts local draft without Core journey',
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
                .having((s) => s.currentStep, 'currentStep', 1)
                .having((s) => s.journey, 'journey', isNull),
          ]),
        );

        final draft = await draftStorage.readDraft();
        expect(draft, isNotNull);
        expect(draft!.currentStep, 1);
        expect(draft.activeJourneyId, isNull);
      },
    );

    test(
      'NextStepEvent advances locally and persists users-defaults draft',
      () async {
        bloc.add(const InitializeWizardEvent());
        await bloc.stream.firstWhere(
          (s) => s.status == PlanningWizardStatus.editing,
        );

        bloc.add(
          const UpdateDestinationAtEvent(
            0,
            PlanningDestination(
              providerPlaceId: 'place_paris_001',
              name: 'Paris',
              arrivalDate: '2026-09-01',
              arrivalTime: '09:00',
              departureDate: '2026-09-05',
              departureTime: '18:00',
              order: 0,
            ),
          ),
        );
        await Future<void>.delayed(Duration.zero);

        bloc.add(const NextStepEvent());
        await bloc.stream.firstWhere((s) => s.currentStep == 2);
        expect(bloc.state.currentStep, 2);

        final draft = await draftStorage.readDraft();
        expect(draft?.currentStep, 2);
        expect(draft?.destinations?.single['name'], 'Paris');
        expect(draft?.isDirty, true);
        // No Core journey yet — POST only at finalize.
        expect(bloc.state.journey, isNull);

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

    test(
      'NextStepEvent advances even if Core update would fail (local-only Q&A)',
      () async {
        bloc.add(const InitializeWizardEvent());
        await bloc.stream.firstWhere(
          (s) => s.status == PlanningWizardStatus.editing,
        );

        bloc.add(
          const UpdateDestinationAtEvent(
            0,
            PlanningDestination(
              providerPlaceId: 'place_lisboa_001',
              name: 'Lisboa',
              arrivalDate: '2026-10-01',
              arrivalTime: '09:00',
              departureDate: '2026-10-05',
              departureTime: '18:00',
              order: 0,
            ),
          ),
        );
        await bloc.stream.firstWhere(
          (s) => s.destinations.first.name == 'Lisboa',
        );

        apiClient.failUpdate = true;
        bloc.add(const NextStepEvent());
        await bloc.stream.firstWhere((s) => s.currentStep == 2);

        expect(bloc.state.currentStep, 2);
        expect(bloc.state.status, PlanningWizardStatus.editing);
        final draft = await draftStorage.readDraft();
        expect(draft?.destinations?.single['name'], 'Lisboa');
        expect(draft?.currentStep, 2);
      },
    );

    test(
      'InitializeWizardEvent restores local draft without journey id',
      () async {
        await draftStorage.saveDraft(
          PlanningDraft(
            currentStep: 3,
            destinations: const [
              {
                'providerPlaceId': 'ChIJu46S-ZZhLxMROG5lkwZ3D7k',
                'name': 'Roma',
                'arrivalDate': '2026-07-25',
                'arrivalTime': '09:00',
                'departureDate': '2026-07-28',
                'departureTime': '23:00',
                'order': 0,
              },
            ],
            travelers: const {'adults': 2, 'children': 2, 'elders': 0},
            interests: const ['GASTRONOMY', 'MUSIC'],
            isDirty: true,
          ),
        );

        bloc.add(const InitializeWizardEvent());
        await bloc.stream.firstWhere(
          (s) => s.status == PlanningWizardStatus.editing,
        );

        expect(bloc.state.currentStep, 3);
        expect(bloc.state.destinations.single.name, 'Roma');
        expect(bloc.state.travelers.adults, 2);
        expect(bloc.state.travelers.children, 2);
        expect(bloc.state.interests, const [
          PlanningInterest.gastronomy,
          PlanningInterest.music,
        ]);
        expect(bloc.state.journey, isNull);
      },
    );

    test(
      'InitializeWizardEvent fills destination, travelers, interests and window from GET',
      () async {
        await createUseCase();
        await repository.updateJourney(
          journeyId: 'journey-123',
          currentStep: 4,
          destinations: const [
            PlanningDestination(
              providerPlaceId: 'place-lisboa',
              name: 'Lisboa',
              arrivalDate: '2026-10-01',
              arrivalTime: '09:00',
              departureDate: '2026-10-05',
              departureTime: '18:00',
            ),
          ],
          travelers: const PlanningTravelers(adults: 2, children: 1, elders: 0),
          interests: const [
            PlanningInterest.geekCulture,
            PlanningInterest.localHistory,
          ],
          activityWindow: const PlanningActivityWindow(
            start: '10:00',
            end: '19:00',
          ),
        );

        bloc.add(const InitializeWizardEvent());
        await bloc.stream.firstWhere(
          (s) => s.status == PlanningWizardStatus.editing,
        );

        expect(bloc.state.currentStep, 4);
        expect(bloc.state.destinations.single.name, 'Lisboa');
        expect(bloc.state.travelers.adults, 2);
        expect(bloc.state.travelers.children, 1);
        expect(bloc.state.interests, const [
          PlanningInterest.geekCulture,
          PlanningInterest.localHistory,
        ]);
        expect(bloc.state.activityWindow.start, '10:00');
        expect(bloc.state.activityWindow.end, '19:00');
      },
    );

    test('GoToStepEvent jumps to target step', () async {
      bloc.add(const InitializeWizardEvent());
      await bloc.stream.firstWhere(
        (s) => s.status == PlanningWizardStatus.editing,
      );

      bloc.add(const GoToStepEvent(5));
      await bloc.stream.firstWhere((s) => s.currentStep == 5);
      expect(bloc.state.currentStep, 5);
    });

    test('step 1 valid when dest name + dates set (placeId optional)', () {
      final state = PlanningWizardState(
        destinations: const [
          PlanningDestination(
            name: 'Roma',
            arrivalDate: '2026-07-25',
            arrivalTime: '09:00',
            departureDate: '2026-07-28',
            departureTime: '23:00',
          ),
        ],
      );
      expect(state.isStep1Valid, isTrue);
    });

    test('step 1 valid when Home seeded real providerPlaceId', () {
      final state = PlanningWizardState(
        destinations: const [
          PlanningDestination(
            providerPlaceId: 'ChIJu46S-ZZhLxMROG5lkwZ3D7k',
            name: 'Roma',
            arrivalDate: '2026-07-25',
            arrivalTime: '09:00',
            departureDate: '2026-07-28',
            departureTime: '23:00',
          ),
        ],
      );
      expect(state.isStep1Valid, isTrue);
    });

    test('step 1 invalid for synthetic catalog: providerPlaceId', () {
      final state = PlanningWizardState(
        destinations: const [
          PlanningDestination(
            providerPlaceId: 'catalog:roma',
            name: 'Roma',
            arrivalDate: '2026-07-25',
            arrivalTime: '09:00',
            departureDate: '2026-07-28',
            departureTime: '23:00',
          ),
        ],
      );
      expect(state.isStep1Valid, isFalse);
    });

    test('step 1 invalid when dates missing even with name', () {
      final state = PlanningWizardState(
        destinations: const [
          PlanningDestination(
            providerPlaceId: 'ChIJu46S-ZZhLxMROG5lkwZ3D7k',
            name: 'Roma',
            arrivalDate: '',
            arrivalTime: '09:00',
            departureDate: '',
            departureTime: '23:00',
          ),
        ],
      );
      expect(state.isStep1Valid, isFalse);
    });
  });
}
