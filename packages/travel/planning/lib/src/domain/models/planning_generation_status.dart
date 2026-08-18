import 'guest_journey_status.dart';

class PlanningGenerationStatus {
  final String journeyId;
  final GuestJourneyStatus status;
  final DateTime? generationStartedAt;
  final DateTime? generationCompletedAt;
  final DateTime? generationFailedAt;
  final String? generationErrorCode;

  const PlanningGenerationStatus({
    required this.journeyId,
    required this.status,
    this.generationStartedAt,
    this.generationCompletedAt,
    this.generationFailedAt,
    this.generationErrorCode,
  });

  bool get isGenerating => status == GuestJourneyStatus.generating;
  bool get isPreviewReady => status == GuestJourneyStatus.previewReady;
  bool get isFailed => status == GuestJourneyStatus.failed;
}
