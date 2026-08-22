import 'package:equatable/equatable.dart';
import 'package:twogo_trips/trips.dart';

sealed class PaidTripHandoffState extends Equatable {
  const PaidTripHandoffState();

  @override
  List<Object?> get props => [];
}

class PaidTripHandoffInitialState extends PaidTripHandoffState {
  const PaidTripHandoffInitialState();
}

class PaidTripHandoffReconcilingState extends PaidTripHandoffState {
  final String tripId;
  final String purchaseId;

  const PaidTripHandoffReconcilingState({
    required this.tripId,
    required this.purchaseId,
  });

  @override
  List<Object?> get props => [tripId, purchaseId];
}

class PaidTripHandoffSuccessState extends PaidTripHandoffState {
  final String tripId;
  final TripEntity trip;

  const PaidTripHandoffSuccessState({
    required this.tripId,
    required this.trip,
  });

  @override
  List<Object?> get props => [tripId, trip];
}

class PaidTripHandoffPendingState extends PaidTripHandoffState {
  final String tripId;
  final String purchaseId;
  final String message;

  const PaidTripHandoffPendingState({
    required this.tripId,
    required this.purchaseId,
    required this.message,
  });

  @override
  List<Object?> get props => [tripId, purchaseId, message];
}

class PaidTripHandoffFailureState extends PaidTripHandoffState {
  final String errorMessage;
  final bool canRetryReconciliation;
  final bool canRetryPayment;

  const PaidTripHandoffFailureState({
    required this.errorMessage,
    this.canRetryReconciliation = false,
    this.canRetryPayment = false,
  });

  @override
  List<Object?> get props => [errorMessage, canRetryReconciliation, canRetryPayment];
}
