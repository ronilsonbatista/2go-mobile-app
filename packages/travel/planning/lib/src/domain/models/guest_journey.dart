import 'guest_journey_status.dart';
import 'planning_activity_window.dart';
import 'planning_destination.dart';
import 'planning_interest.dart';
import 'planning_travelers.dart';

class GuestJourney {
  final String id;
  final GuestJourneyStatus status;
  final int answersVersion;
  final int currentStep;
  final List<PlanningDestination>? destinations;
  final PlanningTravelers? travelers;
  final List<PlanningInterest>? interests;
  final PlanningActivityWindow? activityWindow;
  final String? budgetLevel;
  final String? travelStyle;
  final DateTime expiresAt;

  const GuestJourney({
    required this.id,
    required this.status,
    required this.answersVersion,
    required this.currentStep,
    this.destinations,
    this.travelers,
    this.interests,
    this.activityWindow,
    this.budgetLevel,
    this.travelStyle,
    required this.expiresAt,
  });
}

class CreatedGuestJourneyResult {
  final GuestJourney journey;
  final String guestToken;

  const CreatedGuestJourneyResult({
    required this.journey,
    required this.guestToken,
  });
}
