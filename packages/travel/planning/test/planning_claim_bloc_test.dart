import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_core/twogo_core.dart';
import 'package:twogo_planning/twogo_planning.dart';
import 'package:twogo_security/twogo_security.dart';

class FakeGuestJourneyCredentialStorage
    implements GuestJourneyCredentialStorage {
  final Map<String, String> tokens = {};

  @override
  Future<void> saveGuestToken({
    required String journeyId,
    required String guestToken,
  }) async {
    tokens[journeyId] = guestToken;
  }

  @override
  Future<String?> readGuestToken(String journeyId) async {
    return tokens[journeyId];
  }

  @override
  Future<void> clearGuestToken(String journeyId) async {
    tokens.remove(journeyId);
  }

  @override
  Future<void> clearAllGuestTokens() async {
    tokens.clear();
  }
}

class FakePlanningDraftStorage implements PlanningDraftStorage {
  PlanningDraft? draft;

  @override
  Future<void> saveDraft(PlanningDraft d) async {
    draft = d;
  }

  @override
  Future<PlanningDraft?> readDraft() async {
    return draft;
  }

  @override
  Future<void> clearDraft() async {
    draft = null;
  }
}

class FakePlanningRepository implements PlanningRepository {
  Result<ClaimJourneyResult>? claimResult;
  int claimCalls = 0;

  @override
  Future<Result<ClaimJourneyResult>> claimJourney(String journeyId) async {
    claimCalls++;
    if (claimResult != null) return claimResult!;
    return Result.success(ClaimJourneyResult(
      journeyId: journeyId,
      tripId: 'trip-materialized-123',
      status: 'CLAIMED',
      nextAction: 'CHECKOUT',
    ));
  }

  @override
  Future<Result<CreatedGuestJourneyResult>> createJourney({
    int? answersVersion,
    int? initialStep,
  }) async =>
      throw UnimplementedError();

  @override
  Future<Result<GuestJourney>> finalizeJourney(String journeyId) async =>
      throw UnimplementedError();

  @override
  Future<Result<PlanningGenerationStatus>> getGenerationStatus(
          String journeyId) async =>
      throw UnimplementedError();

  @override
  Future<Result<GuestJourney>> getJourney(String journeyId) async =>
      throw UnimplementedError();

  @override
  Future<Result<PlanningPreview>> getPreview(String journeyId) async =>
      throw UnimplementedError();

  @override
  Future<Result<PlanningGenerationStatus>> startGeneration(
          String journeyId) async =>
      throw UnimplementedError();

  @override
  Future<Result<GuestJourney>> updateJourney({
    required String journeyId,
    int? currentStep,
    List<PlanningDestination>? destinations,
    PlanningTravelers? travelers,
    List<PlanningInterest>? interests,
    PlanningActivityWindow? activityWindow,
    String? budgetLevel,
    String? travelStyle,
  }) async =>
      throw UnimplementedError();
}

void main() {
  late FakePlanningRepository repository;
  late FakeGuestJourneyCredentialStorage credentialStorage;
  late FakePlanningDraftStorage draftStorage;
  late InMemoryPostAuthIntentStorage intentStorage;
  late ClaimPlanningJourneyUseCase claimUseCase;
  late PlanningClaimBloc bloc;

  setUp(() {
    repository = FakePlanningRepository();
    credentialStorage = FakeGuestJourneyCredentialStorage();
    draftStorage = FakePlanningDraftStorage();
    intentStorage = InMemoryPostAuthIntentStorage();
    claimUseCase = ClaimPlanningJourneyUseCase(repository);

    credentialStorage.saveGuestToken(
      journeyId: 'journey-claim-123',
      guestToken: 'guest-secret-token',
    );
    draftStorage.saveDraft(const PlanningDraft(
      activeJourneyId: 'journey-claim-123',
      answersVersion: 1,
      currentStep: 6,
    ));

    bloc = PlanningClaimBloc(
      claimUseCase: claimUseCase,
      credentialStorage: credentialStorage,
      draftStorage: draftStorage,
      intentStorage: intentStorage,
    );
  });

  group('PlanningClaimBloc Tests', () {
    test(
        'SUCCESS: claims journey, persists RESUME_CHECKOUT, deletes guest token and draft',
        () async {
      bloc.add(const ExecutePlanningClaimEvent(
        journeyId: 'journey-claim-123',
        productId: 'prod-999',
      ));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<PlanningClaimingState>(),
          isA<PlanningClaimedState>(),
        ]),
      );

      final state = bloc.state as PlanningClaimedState;
      expect(state.journeyId, 'journey-claim-123');
      expect(state.tripId, 'trip-materialized-123');
      expect(state.nextAction, 'CHECKOUT');
      expect(state.productId, 'prod-999');

      // Assert Intent Storage updated to RESUME_CHECKOUT
      final savedIntent = await intentStorage.readIntent();
      expect(savedIntent, isNotNull);
      expect(savedIntent!.type, PostAuthIntentType.resumeCheckout);
      expect(savedIntent.tripId, 'trip-materialized-123');
      expect(savedIntent.productId, 'prod-999');

      // Assert Cleanup of guest token and draft
      expect(await credentialStorage.readGuestToken('journey-claim-123'), isNull);
      expect(await draftStorage.readDraft(), isNull);
    });

    test(
        'FAILURE (EXPIRED): deletes guest token, draft, and intent on expired error',
        () async {
      repository.claimResult = Result.failure(const GuestJourneyExpiredFailure());

      bloc.add(const ExecutePlanningClaimEvent(
        journeyId: 'journey-claim-123',
      ));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<PlanningClaimingState>(),
          isA<PlanningClaimFailedState>(),
        ]),
      );

      final state = bloc.state as PlanningClaimFailedState;
      expect(state.canRetry, false);
      expect(state.failure, isA<GuestJourneyExpiredFailure>());

      // Assert cleanup
      expect(await credentialStorage.readGuestToken('journey-claim-123'), isNull);
      expect(await draftStorage.readDraft(), isNull);
      expect(await intentStorage.readIntent(), isNull);
    });

    test(
        'FAILURE (TEMPORARY NETWORK): preserves guest token, draft, and intent for retry',
        () async {
      repository.claimResult =
          Result.failure(const UnknownPlanningFailure('Rede indisponível'));

      bloc.add(const ExecutePlanningClaimEvent(
        journeyId: 'journey-claim-123',
      ));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<PlanningClaimingState>(),
          isA<PlanningClaimFailedState>(),
        ]),
      );

      final state = bloc.state as PlanningClaimFailedState;
      expect(state.canRetry, true);

      // Assert guest token & draft preserved for retry
      expect(await credentialStorage.readGuestToken('journey-claim-123'),
          'guest-secret-token');
      expect(await draftStorage.readDraft(), isNotNull);
    });

    test('DOUBLE TAP: ignores duplicate claim execution while claiming in-flight',
        () async {
      bloc.add(const ExecutePlanningClaimEvent(journeyId: 'journey-claim-123'));
      bloc.add(const ExecutePlanningClaimEvent(journeyId: 'journey-claim-123'));
      bloc.add(const ExecutePlanningClaimEvent(journeyId: 'journey-claim-123'));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<PlanningClaimingState>(),
          isA<PlanningClaimedState>(),
        ]),
      );

      expect(repository.claimCalls, 1);
    });
  });
}
