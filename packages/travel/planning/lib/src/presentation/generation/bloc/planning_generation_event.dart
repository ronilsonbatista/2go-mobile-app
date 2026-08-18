import 'package:flutter/widgets.dart';

sealed class PlanningGenerationEvent {
  const PlanningGenerationEvent();
}

final class StartGenerationEvent extends PlanningGenerationEvent {
  final String journeyId;

  const StartGenerationEvent(this.journeyId);
}

final class CheckGenerationStatusEvent extends PlanningGenerationEvent {
  final String journeyId;

  const CheckGenerationStatusEvent(this.journeyId);
}

final class RetryGenerationEvent extends PlanningGenerationEvent {
  const RetryGenerationEvent();
}

final class AppLifecycleStateChangedEvent extends PlanningGenerationEvent {
  final AppLifecycleState state;

  const AppLifecycleStateChangedEvent(this.state);
}
