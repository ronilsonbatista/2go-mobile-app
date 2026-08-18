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

  group('Use Cases Tests', () {
    test(
      'CreatePlanningJourneyUseCase creates journey, saves token securely, and initializes local draft',
      () async {
        final res = await createUseCase();

        expect(res.isSuccess, true);
        final journey = res.getOrNull()!;
        expect(journey.id, 'journey-123');

        final token = await credentialStorage.readGuestToken('journey-123');
        expect(token, 'secret-token-abc');

        final draft = await draftStorage.readDraft();
        expect(draft?.activeJourneyId, 'journey-123');
        expect(draft?.isDirty, false);
      },
    );

    test(
      'RestorePlanningJourneyUseCase restores journey state when credentials exist',
      () async {
        await createUseCase();

        final res = await restoreUseCase('journey-123');

        expect(res.isSuccess, true);
        expect(res.getOrNull()!.id, 'journey-123');
      },
    );

    test(
      'SavePlanningProgressUseCase updates repository and syncs draft state',
      () async {
        await createUseCase();

        final res = await saveUseCase(
          journeyId: 'journey-123',
          currentStep: 3,
          budgetLevel: 'HIGH',
        );

        expect(res.isSuccess, true);
        expect(res.getOrNull()!.currentStep, 3);

        final draft = await draftStorage.readDraft();
        expect(draft?.currentStep, 3);
        expect(draft?.budgetLevel, 'HIGH');
      },
    );

    test(
      'FinalizePlanningJourneyUseCase finalizes journey and locks local draft state',
      () async {
        await createUseCase();

        final res = await finalizeUseCase('journey-123');

        expect(res.isSuccess, true);
        expect(res.getOrNull()!.status, GuestJourneyStatus.readyToGenerate);
      },
    );
  });
}
