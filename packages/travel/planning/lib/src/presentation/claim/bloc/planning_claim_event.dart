import 'package:equatable/equatable.dart';

sealed class PlanningClaimEvent extends Equatable {
  const PlanningClaimEvent();

  @override
  List<Object?> get props => [];
}

final class ExecutePlanningClaimEvent extends PlanningClaimEvent {
  final String journeyId;
  final String? productId;

  const ExecutePlanningClaimEvent({required this.journeyId, this.productId});

  @override
  List<Object?> get props => [journeyId, productId];
}

final class RetryPlanningClaimEvent extends PlanningClaimEvent {
  const RetryPlanningClaimEvent();
}
