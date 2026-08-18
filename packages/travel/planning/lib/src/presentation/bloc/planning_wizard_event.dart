import '../../domain/models/planning_activity_window.dart';
import '../../domain/models/planning_destination.dart';
import '../../domain/models/planning_interest.dart';
import '../../domain/models/planning_travelers.dart';

abstract class PlanningWizardEvent {
  const PlanningWizardEvent();
}

class InitializeWizardEvent extends PlanningWizardEvent {
  final String? journeyId;

  const InitializeWizardEvent({this.journeyId});
}

class NextStepEvent extends PlanningWizardEvent {
  final Map<String, dynamic>? stepData;

  const NextStepEvent({this.stepData});
}

class PreviousStepEvent extends PlanningWizardEvent {
  const PreviousStepEvent();
}

class GoToStepEvent extends PlanningWizardEvent {
  final int step;

  const GoToStepEvent(this.step);
}

class FinalizeWizardEvent extends PlanningWizardEvent {
  const FinalizeWizardEvent();
}

class RetrySyncEvent extends PlanningWizardEvent {
  const RetrySyncEvent();
}

// Step 1 Events
class AddDestinationEvent extends PlanningWizardEvent {
  const AddDestinationEvent();
}

class RemoveDestinationEvent extends PlanningWizardEvent {
  final int index;

  const RemoveDestinationEvent(this.index);
}

class UpdateDestinationAtEvent extends PlanningWizardEvent {
  final int index;
  final PlanningDestination destination;

  const UpdateDestinationAtEvent(this.index, this.destination);
}

// Step 2 Events
class UpdateTravelersEvent extends PlanningWizardEvent {
  final PlanningTravelers travelers;

  const UpdateTravelersEvent(this.travelers);
}

// Step 3 Events
class ToggleInterestEvent extends PlanningWizardEvent {
  final PlanningInterest interest;

  const ToggleInterestEvent(this.interest);
}

class UpdateInterestsEvent extends PlanningWizardEvent {
  final List<PlanningInterest> interests;

  const UpdateInterestsEvent(this.interests);
}

// Step 4 Events
class UpdateActivityWindowEvent extends PlanningWizardEvent {
  final PlanningActivityWindow activityWindow;

  const UpdateActivityWindowEvent(this.activityWindow);
}

// Step 5 Events
class SelectBudgetLevelEvent extends PlanningWizardEvent {
  final String budgetLevel;

  const SelectBudgetLevelEvent(this.budgetLevel);
}

// Review / Navigation Events
class EditSectionEvent extends PlanningWizardEvent {
  final int targetStep;

  const EditSectionEvent(this.targetStep);
}
