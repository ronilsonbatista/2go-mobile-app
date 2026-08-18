import '../../domain/models/guest_journey.dart';
import '../../domain/models/planning_activity_window.dart';
import '../../domain/models/planning_destination.dart';
import '../../domain/models/planning_draft.dart';
import '../../domain/models/planning_interest.dart';
import '../../domain/models/planning_travelers.dart';

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
  final List<PlanningDestination> destinations;
  final PlanningTravelers travelers;
  final List<PlanningInterest> interests;
  final PlanningActivityWindow activityWindow;
  final String? budgetLevel;
  final bool returnToReview;
  final String? errorMessage;
  final bool isDirty;

  const PlanningWizardState({
    this.status = PlanningWizardStatus.initial,
    this.currentStep = 1,
    this.totalSteps = 6,
    this.journey,
    this.draft,
    this.destinations = const [
      PlanningDestination(
        name: '',
        arrivalDate: '',
        arrivalTime: '09:00',
        departureDate: '',
        departureTime: '18:00',
        order: 0,
      ),
    ],
    this.travelers = const PlanningTravelers(adults: 1, children: 0, elders: 0),
    this.interests = const [],
    this.activityWindow = const PlanningActivityWindow(
      start: '09:00',
      end: '18:30',
    ),
    this.budgetLevel,
    this.returnToReview = false,
    this.errorMessage,
    this.isDirty = false,
  });

  double get progressFraction => (currentStep / totalSteps).clamp(0.0, 1.0);

  bool get isStep1Valid {
    if (destinations.isEmpty) return false;
    for (int i = 0; i < destinations.length; i++) {
      final d = destinations[i];
      if (d.providerPlaceId == null || d.providerPlaceId!.trim().isEmpty) {
        return false;
      }
      if (d.arrivalDate.trim().isEmpty || d.departureDate.trim().isEmpty) {
        return false;
      }
      final arr = DateTime.tryParse(d.arrivalDate);
      final dep = DateTime.tryParse(d.departureDate);
      if (arr == null || dep == null) return false;
      if (arr.isAfter(dep)) return false;

      // Chronology across multiple destinations
      if (i > 0) {
        final prevDep = DateTime.tryParse(destinations[i - 1].departureDate);
        if (prevDep != null && arr.isBefore(prevDep)) return false;
      }
    }
    return true;
  }

  bool get isStep2Valid => travelers.total > 0;

  bool get isStep3Valid => interests.isNotEmpty;

  bool get isStep4Valid =>
      activityWindow.startTime.isNotEmpty &&
      activityWindow.endTime.isNotEmpty &&
      activityWindow.startTime.compareTo(activityWindow.endTime) < 0;

  bool get isStep5Valid => budgetLevel != null && budgetLevel!.isNotEmpty;

  bool get isCurrentStepValid {
    switch (currentStep) {
      case 1:
        return isStep1Valid;
      case 2:
        return isStep2Valid;
      case 3:
        return isStep3Valid;
      case 4:
        return isStep4Valid;
      case 5:
        return isStep5Valid;
      case 6:
      default:
        return true;
    }
  }

  PlanningWizardState copyWith({
    PlanningWizardStatus? status,
    int? currentStep,
    int? totalSteps,
    GuestJourney? journey,
    PlanningDraft? draft,
    List<PlanningDestination>? destinations,
    PlanningTravelers? travelers,
    List<PlanningInterest>? interests,
    PlanningActivityWindow? activityWindow,
    String? budgetLevel,
    bool? returnToReview,
    String? errorMessage,
    bool? isDirty,
  }) {
    return PlanningWizardState(
      status: status ?? this.status,
      currentStep: currentStep ?? this.currentStep,
      totalSteps: totalSteps ?? this.totalSteps,
      journey: journey ?? this.journey,
      draft: draft ?? this.draft,
      destinations: destinations ?? this.destinations,
      travelers: travelers ?? this.travelers,
      interests: interests ?? this.interests,
      activityWindow: activityWindow ?? this.activityWindow,
      budgetLevel: budgetLevel ?? this.budgetLevel,
      returnToReview: returnToReview ?? this.returnToReview,
      errorMessage: errorMessage ?? this.errorMessage,
      isDirty: isDirty ?? this.isDirty,
    );
  }
}
