import 'package:twogo_core/twogo_core.dart';
import '../domain/models/guest_journey.dart';
import '../domain/models/planning_draft.dart';
import '../domain/repositories/planning_draft_storage.dart';
import '../domain/repositories/planning_repository.dart';

class FinalizePlanningJourneyUseCase {
  final PlanningRepository _repository;
  final PlanningDraftStorage _draftStorage;

  FinalizePlanningJourneyUseCase({
    required PlanningRepository repository,
    required PlanningDraftStorage draftStorage,
  }) : _repository = repository,
       _draftStorage = draftStorage;

  Future<Result<GuestJourney>> call(String journeyId) async {
    final result = await _repository.finalizeJourney(journeyId);

    return result.fold((finalized) async {
      final currentDraft = await _draftStorage.readDraft();
      await _draftStorage.saveDraft(
        (currentDraft ?? const PlanningDraft()).copyWith(
          activeJourneyId: finalized.id,
          currentStep: finalized.currentStep,
          lastSyncedAt: DateTime.now(),
          isDirty: false,
        ),
      );
      return Result.success(finalized);
    }, (failure) => Result.failure(failure));
  }
}
