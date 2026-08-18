import '../../domain/models/guest_journey.dart';
import '../../domain/models/planning_draft.dart';

enum PlanningWizardStatus {
  initial,
  loading,
  editing,
  submitting,
  syncing,
  success,
  failure,
  finalized,
  exit,
}

class PlanningWizardState {
  final PlanningWizardStatus status;
  final int currentStep;
  final int totalSteps;
  final GuestJourney? journey;
  final PlanningDraft? draft;
  final String? errorMessage;
  final bool isDirty;

  const PlanningWizardState({
    this.status = PlanningWizardStatus.initial,
    this.currentStep = 1,
    this.totalSteps = 6,
    this.journey,
    this.draft,
    this.errorMessage,
    this.isDirty = false,
  });

  double get progressFraction => (currentStep / totalSteps).clamp(0.0, 1.0);

  PlanningWizardState copyWith({
    PlanningWizardStatus? status,
    int? currentStep,
    int? totalSteps,
    GuestJourney? journey,
    PlanningDraft? draft,
    String? errorMessage,
    bool? isDirty,
  }) {
    return PlanningWizardState(
      status: status ?? this.status,
      currentStep: currentStep ?? this.currentStep,
      totalSteps: totalSteps ?? this.totalSteps,
      journey: journey ?? this.journey,
      draft: draft ?? this.draft,
      errorMessage: errorMessage ?? this.errorMessage,
      isDirty: isDirty ?? this.isDirty,
    );
  }
}
