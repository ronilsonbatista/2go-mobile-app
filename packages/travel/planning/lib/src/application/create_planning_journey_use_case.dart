import 'package:twogo_core/twogo_core.dart';
import 'package:twogo_security/twogo_security.dart';
import '../domain/models/guest_journey.dart';
import '../domain/models/planning_draft.dart';
import '../domain/repositories/planning_draft_storage.dart';
import '../domain/repositories/planning_repository.dart';

class CreatePlanningJourneyUseCase {
  final PlanningRepository _repository;
  final GuestJourneyCredentialStorage _credentialStorage;
  final PlanningDraftStorage _draftStorage;

  CreatePlanningJourneyUseCase({
    required PlanningRepository repository,
    required GuestJourneyCredentialStorage credentialStorage,
    required PlanningDraftStorage draftStorage,
  }) : _repository = repository,
       _credentialStorage = credentialStorage,
       _draftStorage = draftStorage;

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

      // Preserve local Q&A answers (e.g. Home → users-defaults destination)
      // instead of wiping the draft when a guest session is created.
      final existing = await _draftStorage.readDraft();
      await _draftStorage.saveDraft(
        PlanningDraft(
          activeJourneyId: created.journey.id,
          currentStep: created.journey.currentStep,
          destinations: existing?.destinations,
          travelers: existing?.travelers,
          interests: existing?.interests,
          activityWindow: existing?.activityWindow,
          budgetLevel: existing?.budgetLevel,
          travelStyle: existing?.travelStyle,
          answersVersion: created.journey.answersVersion,
          lastSyncedAt: DateTime.now(),
          isDirty: existing?.destinations != null &&
              existing!.destinations!.isNotEmpty,
        ),
      );

      return Result.success(created.journey);
    }, (failure) => Result.failure(failure));
  }
}
