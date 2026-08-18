import 'package:twogo_core/twogo_core.dart';
import '../domain/models/guest_journey.dart';
import '../domain/models/planning_activity_window.dart';
import '../domain/models/planning_destination.dart';
import '../domain/models/planning_draft.dart';
import '../domain/models/planning_interest.dart';
import '../domain/models/planning_travelers.dart';
import '../domain/repositories/planning_draft_storage.dart';
import '../domain/repositories/planning_repository.dart';
import '../infrastructure/storage/persistent_planning_draft_storage.dart';

class SavePlanningProgressUseCase {
  final PlanningRepository _repository;
  final PlanningDraftStorage _draftStorage;

  SavePlanningProgressUseCase({
    required PlanningRepository repository,
    PlanningDraftStorage? draftStorage,
  }) : _repository = repository,
       _draftStorage = draftStorage ?? PersistentPlanningDraftStorage();

  Future<Result<GuestJourney>> call({
    required String journeyId,
    int? currentStep,
    List<PlanningDestination>? destinations,
    PlanningTravelers? travelers,
    List<PlanningInterest>? interests,
    PlanningActivityWindow? activityWindow,
    String? budgetLevel,
    String? travelStyle,
  }) async {
    final result = await _repository.updateJourney(
      journeyId: journeyId,
      currentStep: currentStep,
      destinations: destinations,
      travelers: travelers,
      interests: interests,
      activityWindow: activityWindow,
      budgetLevel: budgetLevel,
      travelStyle: travelStyle,
    );

    return result.fold((updated) async {
      final currentDraft = await _draftStorage.readDraft();
      await _draftStorage.saveDraft(
        (currentDraft ?? const PlanningDraft()).copyWith(
          activeJourneyId: updated.id,
          currentStep: updated.currentStep,
          destinations: destinations != null
              ? destinations.map((d) => d.toJson()).toList()
              : currentDraft?.destinations,
          travelers: travelers != null
              ? travelers.toJson()
              : currentDraft?.travelers,
          budgetLevel: updated.budgetLevel,
          travelStyle: updated.travelStyle,
          lastSyncedAt: DateTime.now(),
          isDirty: false,
        ),
      );
      return Result.success(updated);
    }, (failure) => Result.failure(failure));
  }
}
