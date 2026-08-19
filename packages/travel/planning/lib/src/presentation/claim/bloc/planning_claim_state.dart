import 'package:equatable/equatable.dart';
import 'package:twogo_core/twogo_core.dart';

sealed class PlanningClaimState extends Equatable {
  const PlanningClaimState();

  @override
  List<Object?> get props => [];
}

final class PlanningClaimInitialState extends PlanningClaimState {
  const PlanningClaimInitialState();
}

final class PlanningClaimingState extends PlanningClaimState {
  final String journeyId;

  const PlanningClaimingState({required this.journeyId});

  @override
  List<Object?> get props => [journeyId];
}

final class PlanningClaimedState extends PlanningClaimState {
  final String journeyId;
  final String tripId;
  final String nextAction;
  final String? productId;

  const PlanningClaimedState({
    required this.journeyId,
    required this.tripId,
    required this.nextAction,
    this.productId,
  });

  @override
  List<Object?> get props => [journeyId, tripId, nextAction, productId];
}

final class PlanningClaimFailedState extends PlanningClaimState {
  final String journeyId;
  final AppFailure failure;
  final bool canRetry;

  const PlanningClaimFailedState({
    required this.journeyId,
    required this.failure,
    required this.canRetry,
  });

  @override
  List<Object?> get props => [journeyId, failure, canRetry];
}
