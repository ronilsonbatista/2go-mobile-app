import 'package:twogo_core/twogo_core.dart';
import '../models/guest_journey.dart';
import '../models/planning_activity_window.dart';
import '../models/planning_destination.dart';
import '../models/planning_generation_status.dart';
import '../models/planning_interest.dart';
import '../models/planning_preview.dart';
import '../models/planning_travelers.dart';

abstract interface class PlanningRepository {
  Future<Result<CreatedGuestJourneyResult>> createJourney({
    int? answersVersion,
    int? initialStep,
  });

  Future<Result<GuestJourney>> getJourney(String journeyId);

  Future<Result<GuestJourney>> updateJourney({
    required String journeyId,
    int? currentStep,
    List<PlanningDestination>? destinations,
    PlanningTravelers? travelers,
    List<PlanningInterest>? interests,
    PlanningActivityWindow? activityWindow,
    String? budgetLevel,
    String? travelStyle,
  });

  Future<Result<GuestJourney>> finalizeJourney(String journeyId);

  Future<Result<PlanningGenerationStatus>> startGeneration(String journeyId);

  Future<Result<PlanningGenerationStatus>> getGenerationStatus(
    String journeyId,
  );

  Future<Result<PlanningPreview>> getPreview(String journeyId);
}
