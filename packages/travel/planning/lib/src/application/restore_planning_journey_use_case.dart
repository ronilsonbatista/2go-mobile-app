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
      return Result.failure(const MissingGuestJourneyCredentialFailure());
    }

    final result = await _repository.getJourney(journeyId);

    return result.fold((journey) async {
      await _draftStorage.saveDraft(
        PlanningDraft(
          activeJourneyId: journey.id,
          currentStep: journey.currentStep,
          answersVersion: journey.answersVersion,
          budgetLevel: journey.budgetLevel,
          travelStyle: journey.travelStyle,
          lastSyncedAt: DateTime.now(),
          isDirty: false,
        ),
      );
      return Result.success(journey);
    }, (failure) => Result.failure(failure));
  }
}
