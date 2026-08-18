import 'package:app_roteiros_api/app_roteiros_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_planning/twogo_planning.dart';
import 'package:twogo_security/twogo_security.dart';

class FakeGuestJourneyCredentialStorage
    implements GuestJourneyCredentialStorage {
  final Map<String, String> _tokens = {};

  @override
  Future<void> saveGuestToken({
    required String journeyId,
    required String guestToken,
  }) async {
    _tokens[journeyId] = guestToken;
  }

  @override
  Future<String?> readGuestToken(String journeyId) async {
    return _tokens[journeyId];
  }

  @override
  Future<void> clearGuestToken(String journeyId) async {
    _tokens.remove(journeyId);
  }

  @override
  Future<void> clearAllGuestTokens() async {
    _tokens.clear();
  }
}

class FakePlanningApiClient implements PlanningApiClient {
  final Map<String, PlanningSessionResponseDto> sessions = {};
  int createCalls = 0;

  @override
  Future<CreatePlanningSessionResponseDto> createSession(
    CreatePlanningSessionDto dto,
  ) async {
    createCalls++;
    const id = 'journey-123';
    const token = 'secret-token-abc';
    final response = CreatePlanningSessionResponseDto(
      id: id,
      status: 'COLLECTING',
      answersVersion: dto.answersVersion ?? 1,
      currentStep: dto.initialStep ?? 1,
      expiresAt: DateTime.now().add(const Duration(days: 7)).toIso8601String(),
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
      guestToken: token,
    );
    sessions[id] = response;
    return response;
  }

  @override
  Future<PlanningSessionResponseDto> getSession(
    String id, {
    required String guestToken,
  }) async {
    if (guestToken != 'secret-token-abc') {
      throw DioException(
        requestOptions: RequestOptions(path: '/planning-sessions/$id'),
        response: Response(
          requestOptions: RequestOptions(path: '/planning-sessions/$id'),
          statusCode: 404,
          data: {
            'code': 'PLANNING_JOURNEY_INVALID_TOKEN',
            'message': 'Token inválido',
          },
        ),
      );
    }
    final s = sessions[id];
    if (s == null) {
      throw DioException(
        requestOptions: RequestOptions(path: '/planning-sessions/$id'),
        response: Response(
          requestOptions: RequestOptions(path: '/planning-sessions/$id'),
          statusCode: 404,
          data: {
            'code': 'PLANNING_JOURNEY_NOT_FOUND',
            'message': 'Jornada não encontrada',
          },
        ),
      );
    }
    return s;
  }

  @override
  Future<PlanningSessionResponseDto> updateProgress(
    String id,
    UpdatePlanningSessionDto dto, {
    required String guestToken,
  }) async {
    final s = await getSession(id, guestToken: guestToken);
    final updated = PlanningSessionResponseDto(
      id: s.id,
      status: s.status,
      answersVersion: s.answersVersion,
      currentStep: dto.currentStep ?? s.currentStep,
      destinations: dto.destinations ?? s.destinations,
      travelers: dto.travelers ?? s.travelers,
      interests: dto.interests ?? s.interests,
      activityHours: dto.activityWindow ?? s.activityHours,
      travelStyle: dto.travelStyle ?? s.travelStyle,
      budgetLevel: dto.budgetLevel ?? s.budgetLevel,
      expiresAt: s.expiresAt,
      createdAt: s.createdAt,
      updatedAt: DateTime.now().toIso8601String(),
    );
    sessions[id] = updated;
    return updated;
  }

  @override
  Future<PlanningSessionResponseDto> finalizeQuestionnaire(
    String id, {
    required String guestToken,
  }) async {
    final s = await getSession(id, guestToken: guestToken);
    final finalized = PlanningSessionResponseDto(
      id: s.id,
      status: 'READY_TO_GENERATE',
      answersVersion: s.answersVersion,
      currentStep: 6,
      destinations: s.destinations,
      travelers: s.travelers,
      interests: s.interests,
      activityHours: s.activityHours,
      travelStyle: s.travelStyle,
      budgetLevel: s.budgetLevel,
      expiresAt: s.expiresAt,
      createdAt: s.createdAt,
      updatedAt: DateTime.now().toIso8601String(),
    );
    sessions[id] = finalized;
    return finalized;
  }
}

void main() {
  late FakePlanningApiClient apiClient;
  late FakeGuestJourneyCredentialStorage credentialStorage;
  late PlanningRepositoryImpl repository;

  setUp(() {
    apiClient = FakePlanningApiClient();
    credentialStorage = FakeGuestJourneyCredentialStorage();
    repository = PlanningRepositoryImpl(
      apiClient: apiClient,
      credentialStorage: credentialStorage,
    );
  });

  group('PlanningRepository Tests', () {
    test(
      'createJourney creates session and exposes secret guestToken in result',
      () async {
        final res = await repository.createJourney(answersVersion: 1);

        expect(res.isSuccess, true);
        final created = res.getOrNull()!;
        expect(created.journey.id, 'journey-123');
        expect(created.guestToken, 'secret-token-abc');
        expect(created.journey.status, GuestJourneyStatus.collecting);
      },
    );

    test(
      'getJourney fails with MissingGuestJourneyCredentialFailure if token not stored',
      () async {
        final res = await repository.getJourney('journey-123');

        expect(res.isFailure, true);
        expect(
          res.exceptionOrNull(),
          isA<MissingGuestJourneyCredentialFailure>(),
        );
      },
    );

    test('getJourney succeeds when credential token is stored', () async {
      await credentialStorage.saveGuestToken(
        journeyId: 'journey-123',
        guestToken: 'secret-token-abc',
      );
      await apiClient.createSession(const CreatePlanningSessionDto());

      final res = await repository.getJourney('journey-123');

      expect(res.isSuccess, true);
      final journey = res.getOrNull()!;
      expect(journey.id, 'journey-123');
      expect(journey.status, GuestJourneyStatus.collecting);
    });

    test(
      'updateJourney and finalizeJourney update status to readyToGenerate',
      () async {
        await credentialStorage.saveGuestToken(
          journeyId: 'journey-123',
          guestToken: 'secret-token-abc',
        );
        await apiClient.createSession(const CreatePlanningSessionDto());

        final updateRes = await repository.updateJourney(
          journeyId: 'journey-123',
          currentStep: 2,
          budgetLevel: 'MEDIUM',
        );
        expect(updateRes.isSuccess, true);
        expect(updateRes.getOrNull()!.currentStep, 2);

        final finalizeRes = await repository.finalizeJourney('journey-123');
        expect(finalizeRes.isSuccess, true);
        expect(
          finalizeRes.getOrNull()!.status,
          GuestJourneyStatus.readyToGenerate,
        );
      },
    );
  });
}
