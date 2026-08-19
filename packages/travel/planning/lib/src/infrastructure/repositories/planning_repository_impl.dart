import 'package:app_roteiros_api/app_roteiros_api.dart';
import 'package:dio/dio.dart';
import 'package:twogo_core/twogo_core.dart';
import 'package:twogo_security/twogo_security.dart';
import '../../domain/failures/planning_failures.dart';
import '../../domain/models/claim_journey_result.dart';
import '../../domain/models/guest_journey.dart';
import '../../domain/models/planning_activity_window.dart';
import '../../domain/models/planning_destination.dart';
import '../../domain/models/planning_generation_status.dart';
import '../../domain/models/planning_interest.dart';
import '../../domain/models/planning_preview.dart';
import '../../domain/models/planning_travelers.dart';
import '../../domain/repositories/planning_repository.dart';
import '../planning_mapper.dart';

class PlanningRepositoryImpl implements PlanningRepository {
  final PlanningApiClient _apiClient;
  final GuestJourneyCredentialStorage _credentialStorage;

  PlanningRepositoryImpl({
    required PlanningApiClient apiClient,
    required GuestJourneyCredentialStorage credentialStorage,
  }) : _apiClient = apiClient,
       _credentialStorage = credentialStorage;

  @override
  Future<Result<CreatedGuestJourneyResult>> createJourney({
    int? answersVersion,
    int? initialStep,
  }) async {
    try {
      final response = await _apiClient.createSession(
        CreatePlanningSessionDto(
          answersVersion: answersVersion,
          initialStep: initialStep,
        ),
      );
      return Result.success(PlanningMapper.toCreatedResult(response));
    } catch (e) {
      return Result.failure(_mapError(e));
    }
  }

  @override
  Future<Result<GuestJourney>> getJourney(String journeyId) async {
    final token = await _credentialStorage.readGuestToken(journeyId);
    if (token == null || token.isEmpty) {
      return Result.failure(const MissingGuestJourneyCredentialFailure());
    }

    try {
      final response = await _apiClient.getSession(
        journeyId,
        guestToken: token,
      );
      return Result.success(PlanningMapper.toDomain(response));
    } catch (e) {
      return Result.failure(_mapError(e));
    }
  }

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
  }) async {
    final token = await _credentialStorage.readGuestToken(journeyId);
    if (token == null || token.isEmpty) {
      return Result.failure(const MissingGuestJourneyCredentialFailure());
    }

    try {
      final dto = UpdatePlanningSessionDto(
        currentStep: currentStep,
        destinations: destinations
            ?.map((d) => PlanningMapper.destinationToDto(d))
            .toList(),
        travelers: travelers != null
            ? PlanningMapper.travelersToDto(travelers)
            : null,
        interests: interests?.map((e) => e.toRaw()).toList(),
        activityWindow: activityWindow != null
            ? PlanningMapper.activityWindowToDto(activityWindow)
            : null,
        budgetLevel: budgetLevel,
        travelStyle: travelStyle,
      );

      final response = await _apiClient.updateProgress(
        journeyId,
        dto,
        guestToken: token,
      );
      return Result.success(PlanningMapper.toDomain(response));
    } catch (e) {
      return Result.failure(_mapError(e));
    }
  }

  @override
  Future<Result<GuestJourney>> finalizeJourney(String journeyId) async {
    final token = await _credentialStorage.readGuestToken(journeyId);
    if (token == null || token.isEmpty) {
      return Result.failure(const MissingGuestJourneyCredentialFailure());
    }

    try {
      final response = await _apiClient.finalizeQuestionnaire(
        journeyId,
        guestToken: token,
      );
      return Result.success(PlanningMapper.toDomain(response));
    } catch (e) {
      return Result.failure(_mapError(e));
    }
  }

  @override
  Future<Result<PlanningGenerationStatus>> startGeneration(
    String journeyId,
  ) async {
    final token = await _credentialStorage.readGuestToken(journeyId);
    if (token == null || token.isEmpty) {
      return Result.failure(const MissingGuestJourneyCredentialFailure());
    }

    try {
      final response = await _apiClient.startGeneration(
        journeyId,
        guestToken: token,
      );
      return Result.success(PlanningMapper.toGenerationStatusDomain(response));
    } catch (e) {
      return Result.failure(_mapError(e));
    }
  }

  @override
  Future<Result<PlanningGenerationStatus>> getGenerationStatus(
    String journeyId,
  ) async {
    final token = await _credentialStorage.readGuestToken(journeyId);
    if (token == null || token.isEmpty) {
      return Result.failure(const MissingGuestJourneyCredentialFailure());
    }

    try {
      final response = await _apiClient.getGenerationStatus(
        journeyId,
        guestToken: token,
      );
      return Result.success(PlanningMapper.toGenerationStatusDomain(response));
    } catch (e) {
      return Result.failure(_mapError(e));
    }
  }

  @override
  Future<Result<PlanningPreview>> getPreview(String journeyId) async {
    final token = await _credentialStorage.readGuestToken(journeyId);
    if (token == null || token.isEmpty) {
      return Result.failure(const MissingGuestJourneyCredentialFailure());
    }

    try {
      final response = await _apiClient.getPreview(
        journeyId,
        guestToken: token,
      );
      return Result.success(PlanningMapper.toPreviewDomain(response));
    } catch (e) {
      return Result.failure(_mapError(e));
    }
  }

  @override
  Future<Result<ClaimJourneyResult>> claimJourney(String journeyId) async {
    final token = await _credentialStorage.readGuestToken(journeyId);
    if (token == null || token.isEmpty) {
      return Result.failure(const MissingGuestJourneyCredentialFailure());
    }

    try {
      final response = await _apiClient.claimJourney(
        journeyId,
        guestToken: token,
      );
      return Result.success(PlanningMapper.toClaimJourneyDomain(response));
    } catch (e) {
      return Result.failure(_mapError(e));
    }
  }

  AppFailure _mapError(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final code = data['code'] as String?;
        final message = data['message'] as String? ?? 'Erro na requisição';

        switch (code) {
          case 'PLANNING_JOURNEY_NOT_FOUND':
          case 'PLANNING_JOURNEY_INVALID_TOKEN':
            return const GuestJourneyNotFoundFailure();
          case 'PLANNING_JOURNEY_EXPIRED':
            return const GuestJourneyExpiredFailure();
          case 'PLANNING_JOURNEY_LOCKED':
            return const GuestJourneyLockedFailure();
          case 'PLANNING_JOURNEY_ALREADY_CLAIMED':
          case 'PLANNING_JOURNEY_NOT_CLAIMABLE':
          case 'PLANNING_INCOMPLETE':
            return PlanningIncompleteFailure(message);
          case 'PLANNING_INVALID_DESTINATIONS':
          case 'PLANNING_INVALID_TRAVELERS':
          case 'PLANNING_INVALID_ACTIVITY_WINDOW':
            return InvalidPlanningDataFailure(message);
        }
      }
      return UnknownPlanningFailure(
        error.message ?? 'Erro de comunicação com o servidor',
      );
    }
    return UnknownPlanningFailure(error.toString());
  }
}
