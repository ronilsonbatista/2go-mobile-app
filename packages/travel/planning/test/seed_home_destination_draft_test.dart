import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_planning/twogo_planning.dart';

import 'planning_repository_test.dart';

void main() {
  group('SeedHomeDestinationDraftUseCase', () {
    late InMemoryPlanningDraftStorage draftStorage;
    late SeedHomeDestinationDraftUseCase useCase;

    setUp(() {
      draftStorage = InMemoryPlanningDraftStorage();
      useCase = SeedHomeDestinationDraftUseCase(draftStorage: draftStorage);
    });

    test('persists Home selection into users-defaults draft without journey id',
        () async {
      final draft = await useCase(
        name: 'Capadócia',
        country: 'Turquia',
        coverImageUrl: 'https://cdn.example/capadocia.jpg',
        providerPlaceId: 'places/ChIJcapadocia',
        now: DateTime.utc(2026, 11, 18),
      );

      expect(draft.activeJourneyId, isNull);
      expect(draft.currentStep, 1);
      expect(draft.isDirty, isTrue);
      expect(draft.destinations, hasLength(1));

      final destination = PlanningDestination.fromJson(draft.destinations!.first);
      expect(destination.name, 'Capadócia');
      expect(destination.country, 'Turquia');
      expect(destination.coverImage, 'https://cdn.example/capadocia.jpg');
      expect(destination.providerPlaceId, 'places/ChIJcapadocia');
      // Dates stay empty until the user picks them on Onde.
      expect(destination.arrivalDate, isEmpty);
      expect(destination.departureDate, isEmpty);
      expect(draft.travelers?['adults'], 1);

      final stored = await draftStorage.readDraft();
      expect(stored?.destinations?.first['name'], 'Capadócia');
      expect(stored?.destinations?.first['providerPlaceId'],
          'places/ChIJcapadocia');
      expect(stored?.activeJourneyId, isNull);
      expect(stored?.travelers?['adults'], 1);
    });

    test('startEmpty clears city/dates and defaults 1 adulto', () async {
      final draft = await useCase.startEmpty();
      expect(draft.destinations, hasLength(1));
      final destination =
          PlanningDestination.fromJson(draft.destinations!.first);
      expect(destination.name, isEmpty);
      expect(destination.arrivalDate, isEmpty);
      expect(destination.departureDate, isEmpty);
      expect(draft.travelers?['adults'], 1);
      expect(draft.activeJourneyId, isNull);
    });

    test('omits providerPlaceId from draft when Home field is absent', () async {
      final draft = await useCase(
        name: 'Fallback City',
        country: 'BR',
        coverImageUrl: 'https://cdn.example/f.jpg',
      );

      final destination = PlanningDestination.fromJson(draft.destinations!.first);
      expect(destination.providerPlaceId, isNull);
      expect(draft.destinations!.first.containsKey('providerPlaceId'), isFalse);
    });

    test('clears previous activeJourneyId so tap does not PATCH old session',
        () async {
      await draftStorage.saveDraft(
        const PlanningDraft(
          activeJourneyId: 'journey-old',
          currentStep: 3,
          destinations: [
            {'name': 'Paris', 'order': 0},
          ],
          isDirty: false,
        ),
      );

      final draft = await useCase(
        name: 'Rio de Janeiro',
        country: 'Brasil',
        coverImageUrl: 'https://cdn.example/rio.jpg',
      );

      expect(draft.activeJourneyId, isNull);
      expect(draft.currentStep, 1);
      expect(draft.destinations!.first['name'], 'Rio de Janeiro');
    });
  });

  group('CreatePlanningJourneyUseCase preserves draft destinations', () {
    test('does not wipe Home-seeded destinations when session is created',
        () async {
      final apiClient = FakePlanningApiClient();
      final credentialStorage = FakeGuestJourneyCredentialStorage();
      final draftStorage = InMemoryPlanningDraftStorage();
      final repository = PlanningRepositoryImpl(
        apiClient: apiClient,
        credentialStorage: credentialStorage,
      );

      await SeedHomeDestinationDraftUseCase(draftStorage: draftStorage)(
        name: 'Lisboa',
        country: 'Portugal',
        coverImageUrl: 'https://cdn.example/lisboa.jpg',
      );

      final create = CreatePlanningJourneyUseCase(
        repository: repository,
        credentialStorage: credentialStorage,
        draftStorage: draftStorage,
      );

      final result = await create();
      expect(result.isSuccess, isTrue);

      final draft = await draftStorage.readDraft();
      expect(draft?.activeJourneyId, isNotNull);
      expect(draft?.destinations?.first['name'], 'Lisboa');
      expect(draft?.destinations?.first['coverImage'],
          'https://cdn.example/lisboa.jpg');
    });
  });

  group('PlanningWizardBloc Home draft restore', () {
    test('restores seeded destinations without creating a session', () async {
      final apiClient = FakePlanningApiClient();
      final credentialStorage = FakeGuestJourneyCredentialStorage();
      final draftStorage = InMemoryPlanningDraftStorage();
      final repository = PlanningRepositoryImpl(
        apiClient: apiClient,
        credentialStorage: credentialStorage,
      );

      await SeedHomeDestinationDraftUseCase(draftStorage: draftStorage)(
        name: 'Nova York',
        country: 'EUA',
        coverImageUrl: 'https://cdn.example/ny.jpg',
        now: DateTime.utc(2026, 11, 18),
      );

      final sessionsBefore = apiClient.createCalls;

      final bloc = PlanningWizardBloc(
        createUseCase: CreatePlanningJourneyUseCase(
          repository: repository,
          credentialStorage: credentialStorage,
          draftStorage: draftStorage,
        ),
        restoreUseCase: RestorePlanningJourneyUseCase(
          repository: repository,
          credentialStorage: credentialStorage,
          draftStorage: draftStorage,
        ),
        saveUseCase: SavePlanningProgressUseCase(
          repository: repository,
          draftStorage: draftStorage,
        ),
        finalizeUseCase: FinalizePlanningJourneyUseCase(
          repository: repository,
          draftStorage: draftStorage,
        ),
        draftStorage: draftStorage,
      );

      bloc.add(const InitializeWizardEvent());
      await bloc.stream.firstWhere(
        (s) => s.status == PlanningWizardStatus.editing,
      );

      expect(bloc.state.journey, isNull);
      expect(bloc.state.destinations.first.name, 'Nova York');
      expect(bloc.state.destinations.first.coverImage,
          'https://cdn.example/ny.jpg');
      expect(apiClient.createCalls, sessionsBefore);

      await bloc.close();
    });
  });
}
