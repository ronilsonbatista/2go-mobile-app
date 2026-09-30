import 'package:twogo_core/twogo_core.dart';
import '../domain/models/guest_journey.dart';
import '../domain/models/planning_activity_window.dart';
import '../domain/models/planning_destination.dart';
import '../domain/models/planning_draft.dart';
import '../domain/models/planning_interest.dart';
import '../domain/models/planning_travelers.dart';
import '../domain/repositories/planning_draft_storage.dart';
import '../domain/repositories/planning_repository.dart';

class SavePlanningProgressUseCase {
  final PlanningRepository _repository;
  final PlanningDraftStorage _draftStorage;

  SavePlanningProgressUseCase({
    required PlanningRepository repository,
    required PlanningDraftStorage draftStorage,
  }) : _repository = repository,
       _draftStorage = draftStorage;

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

    return result.fold(
      (updated) async {
        await _writeDraft(
          journeyId: updated.id,
          currentStep: updated.currentStep,
          destinations: destinations,
          travelers: travelers,
          interests: interests,
          activityWindow: activityWindow,
          budgetLevel: updated.budgetLevel,
          travelStyle: updated.travelStyle,
          isDirty: false,
          synced: true,
        );
        return Result.success(updated);
      },
      (failure) async {
        try {
          await _writeDraft(
            journeyId: journeyId,
            keepCurrentStep: true,
            destinations: destinations,
            travelers: travelers,
            interests: interests,
            activityWindow: activityWindow,
            budgetLevel: budgetLevel,
            travelStyle: travelStyle,
            isDirty: true,
            synced: false,
          );
        } catch (_) {
          // Sem cópia local o passo não pode avançar; o caller trata a falha.
        }
        return Result.failure(failure);
      },
    );
  }

  Future<void> _writeDraft({
    required String journeyId,
    int? currentStep,
    bool keepCurrentStep = false,
    List<PlanningDestination>? destinations,
    PlanningTravelers? travelers,
    List<PlanningInterest>? interests,
    PlanningActivityWindow? activityWindow,
    String? budgetLevel,
    String? travelStyle,
    required bool isDirty,
    required bool synced,
  }) async {
    final currentDraft = await _draftStorage.readDraft();
    final base = currentDraft ?? const PlanningDraft();
    final step = keepCurrentStep
        ? (currentDraft?.currentStep ?? base.currentStep)
        : (currentStep ?? base.currentStep);

    await _draftStorage.saveDraft(
      base.copyWith(
        activeJourneyId: journeyId,
        currentStep: step,
        destinations: destinations != null
            ? destinations.map((d) => d.toJson()).toList()
            : currentDraft?.destinations,
        travelers: travelers != null
            ? travelers.toJson()
            : currentDraft?.travelers,
        interests: interests != null
            ? interests.map((interest) => interest.toRaw()).toList()
            : currentDraft?.interests,
        activityWindow: activityWindow != null
            ? activityWindow.toJson()
            : currentDraft?.activityWindow,
        budgetLevel: budgetLevel ?? currentDraft?.budgetLevel,
        travelStyle: travelStyle ?? currentDraft?.travelStyle,
        lastSyncedAt: synced ? DateTime.now() : currentDraft?.lastSyncedAt,
        isDirty: isDirty,
      ),
    );
  }
}
