import 'package:twogo_core/twogo_core.dart';
import 'package:twogo_security/twogo_security.dart';
import '../domain/failures/planning_failures.dart';
import '../domain/models/guest_journey.dart';
import '../domain/models/planning_draft.dart';
import '../domain/repositories/planning_draft_storage.dart';
import '../domain/repositories/planning_repository.dart';

class RestorePlanningJourneyUseCase {
  final PlanningRepository _repository;
  final GuestJourneyCredentialStorage _credentialStorage;
  final PlanningDraftStorage _draftStorage;

  RestorePlanningJourneyUseCase({
    required PlanningRepository repository,
    required GuestJourneyCredentialStorage credentialStorage,
    required PlanningDraftStorage draftStorage,
  }) : _repository = repository,
       _credentialStorage = credentialStorage,
       _draftStorage = draftStorage;

  Future<Result<GuestJourney>> call(String journeyId) async {
    final token = await _credentialStorage.readGuestToken(journeyId);
    if (token == null || token.isEmpty) {
      await _draftStorage.clearDraft();
      return Result.failure(const MissingGuestJourneyCredentialFailure());
    }

    final result = await _repository.getJourney(journeyId);

    return result.fold(
      (journey) async {
        final existing = await _draftStorage.readDraft();
        final keepLocal =
            existing != null && existing.activeJourneyId == journey.id;

        await _draftStorage.saveDraft(
          PlanningDraft(
            activeJourneyId: journey.id,
            currentStep: journey.currentStep,
            destinations: _preferLocal(
              keepLocal,
              existing?.destinations,
              journey.destinations?.map((d) => d.toJson()).toList(),
            ),
            travelers: _preferLocal(
              keepLocal,
              existing?.travelers,
              journey.travelers?.toJson(),
            ),
            interests: _preferLocal(
              keepLocal,
              existing?.interests,
              journey.interests?.map((interest) => interest.toRaw()).toList(),
            ),
            activityWindow: _preferLocal(
              keepLocal,
              existing?.activityWindow,
              journey.activityWindow?.toJson(),
            ),
            answersVersion: journey.answersVersion,
            budgetLevel:
                journey.budgetLevel ??
                (keepLocal ? existing.budgetLevel : null),
            travelStyle:
                journey.travelStyle ??
                (keepLocal ? existing.travelStyle : null),
            lastSyncedAt: DateTime.now(),
            isDirty: false,
          ),
        );
        return Result.success(journey);
      },
      (failure) async {
        if (failure is GuestJourneyExpiredFailure ||
            failure is GuestJourneyNotFoundFailure) {
          await _draftStorage.clearDraft();
          await _credentialStorage.clearGuestToken(journeyId);
        }
        return Result.failure(failure);
      },
    );
  }

  T? _preferLocal<T>(bool keepLocal, T? local, T? remote) {
    if (keepLocal && local != null) return local;
    return remote;
  }
}
