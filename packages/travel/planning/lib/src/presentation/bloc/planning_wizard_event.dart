import '../../domain/models/planning_destination.dart';
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
