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
