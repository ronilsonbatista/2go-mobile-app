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

  group('Step 1 — Destinations Validation & Logic Tests', () {
    test('initial state has 1 empty destination and is invalid', () {
      expect(bloc.state.destinations.length, 1);
      expect(bloc.state.isStep1Valid, isFalse);
    });

    test(
      'validates destination when placeId, arrival, departure are valid',
      () async {
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

        expect(bloc.state.isStep1Valid, isTrue);
      },
    );

    test('invalidates when arrival date is after departure date', () async {
      bloc.add(
        const UpdateDestinationAtEvent(
          0,
          PlanningDestination(
            providerPlaceId: 'place_paris_001',
            name: 'Paris',
            arrivalDate: '2026-09-10',
            arrivalTime: '09:00',
            departureDate: '2026-09-05',
            departureTime: '18:00',
            order: 0,
          ),
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.isStep1Valid, isFalse);
    });

    test('adds destination and re-indexes order 0..N', () async {
      bloc.add(const AddDestinationEvent());
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.destinations.length, 2);
      expect(bloc.state.destinations[0].order, 0);
      expect(bloc.state.destinations[1].order, 1);
    });

    test(
      'removes destination safely and maintains minimum 1 destination',
      () async {
        bloc.add(const AddDestinationEvent());
        await Future<void>.delayed(Duration.zero);
        expect(bloc.state.destinations.length, 2);

        bloc.add(const RemoveDestinationEvent(0));
        await Future<void>.delayed(Duration.zero);
        expect(bloc.state.destinations.length, 1);
        expect(bloc.state.destinations[0].order, 0);

        // Attempting to remove the last remaining destination is ignored
        bloc.add(const RemoveDestinationEvent(0));
        await Future<void>.delayed(Duration.zero);
        expect(bloc.state.destinations.length, 1);
      },
    );

    test('validates chronology across multiple destinations', () async {
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

      bloc.add(const AddDestinationEvent());
      await Future<void>.delayed(Duration.zero);

      // Dest 2 arrival BEFORE Dest 1 departure -> Invalid chronology
      bloc.add(
        const UpdateDestinationAtEvent(
          1,
          PlanningDestination(
            providerPlaceId: 'place_rome_002',
            name: 'Roma',
            arrivalDate: '2026-09-03',
            arrivalTime: '09:00',
            departureDate: '2026-09-10',
            departureTime: '18:00',
            order: 1,
          ),
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.isStep1Valid, isFalse);

      // Dest 2 arrival AFTER Dest 1 departure -> Valid chronology
      bloc.add(
        const UpdateDestinationAtEvent(
          1,
          PlanningDestination(
            providerPlaceId: 'place_rome_002',
            name: 'Roma',
            arrivalDate: '2026-09-06',
            arrivalTime: '09:00',
            departureDate: '2026-09-10',
            departureTime: '18:00',
            order: 1,
          ),
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.isStep1Valid, isTrue);
    });
  });
}
