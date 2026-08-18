import 'package:twogo_core/twogo_core.dart';
import 'package:twogo_security/twogo_security.dart';
import '../domain/models/guest_journey.dart';
import '../domain/models/planning_draft.dart';
import '../domain/repositories/planning_draft_storage.dart';
import '../domain/repositories/planning_repository.dart';
import '../infrastructure/storage/persistent_planning_draft_storage.dart';

class CreatePlanningJourneyUseCase {
  final PlanningRepository _repository;
  final GuestJourneyCredentialStorage _credentialStorage;
  final PlanningDraftStorage _draftStorage;

  CreatePlanningJourneyUseCase({
    required PlanningRepository repository,
    required GuestJourneyCredentialStorage credentialStorage,
    PlanningDraftStorage? draftStorage,
  }) : _repository = repository,
       _credentialStorage = credentialStorage,
       _draftStorage = draftStorage ?? PersistentPlanningDraftStorage();

  Future<Result<GuestJourney>> call({
    int? answersVersion,
    int? initialStep,
  }) async {
    final result = await _repository.createJourney(
      answersVersion: answersVersion,
      initialStep: initialStep,
    );

    return result.fold((created) async {
      await _credentialStorage.saveGuestToken(
        journeyId: created.journey.id,
        guestToken: created.guestToken,
      );

      await _draftStorage.saveDraft(
        PlanningDraft(
          activeJourneyId: created.journey.id,
          currentStep: created.journey.currentStep,
          answersVersion: created.journey.answersVersion,
          lastSyncedAt: DateTime.now(),
          isDirty: false,
        ),
      );

      return Result.success(created.journey);
    }, (failure) => Result.failure(failure));
  }
}
