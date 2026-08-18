import '../../../domain/models/planning_generation_status.dart';

enum PlanningGenerationPageStatus {
  initial,
  starting,
  generating,
  temporaryNetworkFailure,
  failed,
  previewReady,
  expired,
}

class PlanningGenerationState {
  final String journeyId;
  final PlanningGenerationPageStatus status;
  final PlanningGenerationStatus? generationStatus;
  final String? errorMessage;

  const PlanningGenerationState({
    this.journeyId = '',
    this.status = PlanningGenerationPageStatus.initial,
    this.generationStatus,
    this.errorMessage,
  });

  PlanningGenerationState copyWith({
    String? journeyId,
    PlanningGenerationPageStatus? status,
    PlanningGenerationStatus? generationStatus,
    String? errorMessage,
  }) {
    return PlanningGenerationState(
      journeyId: journeyId ?? this.journeyId,
      status: status ?? this.status,
      generationStatus: generationStatus ?? this.generationStatus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
