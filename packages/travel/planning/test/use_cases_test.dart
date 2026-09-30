import 'package:app_roteiros_api/app_roteiros_api.dart';
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
      'SavePlanningProgressUseCase stores interests with API codes',
      () async {
        await createUseCase();

        final res = await saveUseCase(
          journeyId: 'journey-123',
          currentStep: 3,
          interests: const [
            PlanningInterest.geekCulture,
            PlanningInterest.localHistory,
          ],
        );

        expect(res.isSuccess, true);
        final draft = await draftStorage.readDraft();
        expect(draft?.interests, ['GEEK_CULTURE', 'LOCAL_HISTORY']);
        expect(draft?.interests!.map(PlanningInterest.fromRaw).toList(), [
          PlanningInterest.geekCulture,
          PlanningInterest.localHistory,
        ]);
      },
    );

    test(
      'SavePlanningProgressUseCase keeps a local copy when the patch fails',
      () async {
        await createUseCase();
        apiClient.failUpdate = true;

        final res = await saveUseCase(
          journeyId: 'journey-123',
          currentStep: 2,
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
          interests: const [
            PlanningInterest.geekCulture,
            PlanningInterest.localHistory,
          ],
        );

        expect(res.isFailure, true);
        final draft = await draftStorage.readDraft();
        expect(draft?.isDirty, true);
        expect(draft?.currentStep, 1);
        expect(draft?.destinations?.single['name'], 'Lisboa');
        expect(draft?.interests, ['GEEK_CULTURE', 'LOCAL_HISTORY']);
      },
    );

    test(
      'RestorePlanningJourneyUseCase keeps local blocks and fills gaps from GET',
      () async {
        await createUseCase();
        await saveUseCase(
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

        final current = apiClient.sessions['journey-123']!;
        apiClient.sessions['journey-123'] = PlanningSessionResponseDto(
          id: current.id,
          status: current.status,
          answersVersion: current.answersVersion,
          currentStep: current.currentStep,
          destinations: null,
          travelers: null,
          interests: const ['NATURE'],
          activityHours: null,
          travelStyle: current.travelStyle,
          budgetLevel: current.budgetLevel,
          expiresAt: current.expiresAt,
          createdAt: current.createdAt,
          updatedAt: current.updatedAt,
        );

        final kept = await restoreUseCase('journey-123');
        expect(kept.isSuccess, true);
        final keptDraft = await draftStorage.readDraft();
        expect(keptDraft?.destinations?.single['name'], 'Lisboa');
        expect(keptDraft?.travelers?['adults'], 2);
        expect(keptDraft?.interests, ['GEEK_CULTURE', 'LOCAL_HISTORY']);
        expect(keptDraft?.activityWindow?['startTime'], '10:00');
        expect(keptDraft?.activityWindow?['endTime'], '19:00');

        await draftStorage.saveDraft(
          PlanningDraft(
            activeJourneyId: 'journey-123',
            currentStep: current.currentStep,
          ),
        );
        apiClient.sessions['journey-123'] = PlanningSessionResponseDto(
          id: current.id,
          status: current.status,
          answersVersion: current.answersVersion,
          currentStep: 4,
          destinations: const [
            PlanningDestinationDto(
              providerPlaceId: 'place-porto',
              name: 'Porto',
              arrivalDate: '2026-11-01',
              arrivalTime: '08:00',
              departureDate: '2026-11-04',
              departureTime: '20:00',
              order: 0,
            ),
          ],
          travelers: const PlanningTravelersDto(
            adults: 3,
            children: 0,
            elders: 1,
          ),
          interests: const ['GEEK_CULTURE', 'LOCAL_HISTORY'],
          activityHours: const PlanningActivityWindowDto(
            startTime: '11:00',
            endTime: '21:00',
          ),
          expiresAt: current.expiresAt,
          createdAt: current.createdAt,
          updatedAt: current.updatedAt,
        );

        final filled = await restoreUseCase('journey-123');
        expect(filled.isSuccess, true);
        final filledDraft = await draftStorage.readDraft();
        expect(filledDraft?.destinations?.single['name'], 'Porto');
        expect(filledDraft?.travelers?['adults'], 3);
        expect(filledDraft?.travelers?['elders'], 1);
        expect(filledDraft?.interests, ['GEEK_CULTURE', 'LOCAL_HISTORY']);
        expect(filledDraft?.activityWindow?['startTime'], '11:00');
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
