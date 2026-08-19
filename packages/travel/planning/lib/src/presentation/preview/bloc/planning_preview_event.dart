import 'package:equatable/equatable.dart';

abstract class PlanningPreviewEvent extends Equatable {
  const PlanningPreviewEvent();

  @override
  List<Object?> get props => [];
}

class FetchPlanningPreviewEvent extends PlanningPreviewEvent {
  final String journeyId;

  const FetchPlanningPreviewEvent({required this.journeyId});

  @override
  List<Object?> get props => [journeyId];
}

class SelectPreviewDayEvent extends PlanningPreviewEvent {
  final int dayNumber;

  const SelectPreviewDayEvent({required this.dayNumber});

  @override
  List<Object?> get props => [dayNumber];
}

class OpenPaywallEvent extends PlanningPreviewEvent {
  final String source; // 'AUTO', 'BANNER', 'LOCKED_DAY'

  const OpenPaywallEvent({required this.source});

  @override
  List<Object?> get props => [source];
}

class DismissPaywallEvent extends PlanningPreviewEvent {
  const DismissPaywallEvent();
}

class RequestUnlockEvent extends PlanningPreviewEvent {
  const RequestUnlockEvent();
}
