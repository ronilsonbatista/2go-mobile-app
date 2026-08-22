import 'package:equatable/equatable.dart';

abstract class CheckoutPaymentState extends Equatable {
  const CheckoutPaymentState();

  @override
  List<Object?> get props => [];
}

class CheckoutPaymentInitialState extends CheckoutPaymentState {
  const CheckoutPaymentInitialState();
}

class CheckoutPaymentProcessingState extends CheckoutPaymentState {
  final String tripId;
  final String paymentMethod;
  final String idempotencyKey;

  const CheckoutPaymentProcessingState({
    required this.tripId,
    required this.paymentMethod,
    required this.idempotencyKey,
  });

  @override
  List<Object?> get props => [tripId, paymentMethod, idempotencyKey];
}

class CheckoutPixPendingState extends CheckoutPaymentState {
  final String purchaseId;
  final String tripId;
  final String? copyPaste;
  final String? qrCodeBase64;
  final String? expiresAt;
  final int remainingSeconds;

  const CheckoutPixPendingState({
    required this.purchaseId,
    required this.tripId,
    this.copyPaste,
    this.qrCodeBase64,
    this.expiresAt,
    required this.remainingSeconds,
  });

  @override
  List<Object?> get props => [
        purchaseId,
        tripId,
        copyPaste,
        qrCodeBase64,
        expiresAt,
        remainingSeconds,
      ];
}

class CheckoutCardAwaitingConfirmationState extends CheckoutPaymentState {
  final String purchaseId;
  final String tripId;

  const CheckoutCardAwaitingConfirmationState({
    required this.purchaseId,
    required this.tripId,
  });

  @override
  List<Object?> get props => [purchaseId, tripId];
}

class CheckoutPaymentRejectedState extends CheckoutPaymentState {
  final String errorMessage;
  final bool canRetry;

  const CheckoutPaymentRejectedState({
    required this.errorMessage,
    this.canRetry = true,
  });

  @override
  List<Object?> get props => [errorMessage, canRetry];
}

class CheckoutPaymentExpiredState extends CheckoutPaymentState {
  final String purchaseId;

  const CheckoutPaymentExpiredState({
    required this.purchaseId,
  });

  @override
  List<Object?> get props => [purchaseId];
}

class PaymentConfirmedByCoreState extends CheckoutPaymentState {
  final String purchaseId;
  final String tripId;

  const PaymentConfirmedByCoreState({
    required this.purchaseId,
    required this.tripId,
  });

  @override
  List<Object?> get props => [purchaseId, tripId];
}

class CheckoutPaymentFailureState extends CheckoutPaymentState {
  final String errorMessage;

  const CheckoutPaymentFailureState({
    required this.errorMessage,
  });

  @override
  List<Object?> get props => [errorMessage];
}
