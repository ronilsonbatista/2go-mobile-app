import 'package:equatable/equatable.dart';
import 'package:twogo_payments/twogo_payments.dart';

sealed class CheckoutState extends Equatable {
  const CheckoutState();

  @override
  List<Object?> get props => [];
}

class CheckoutInitialState extends CheckoutState {
  const CheckoutInitialState();
}

class CheckoutLoadingState extends CheckoutState {
  const CheckoutLoadingState();
}

class CheckoutReadyState extends CheckoutState {
  final CheckoutSummary summary;
  final String selectedPaymentMethod;
  final bool isQuoting;
  final bool isTokenizing;
  final String? quoteError;
  final String? cardTokenError;
  final String? cardToken;

  const CheckoutReadyState({
    required this.summary,
    required this.selectedPaymentMethod,
    this.isQuoting = false,
    this.isTokenizing = false,
    this.quoteError,
    this.cardTokenError,
    this.cardToken,
  });

  CheckoutReadyState copyWith({
    CheckoutSummary? summary,
    String? selectedPaymentMethod,
    bool? isQuoting,
    bool? isTokenizing,
    String? quoteError,
    String? cardTokenError,
    String? cardToken,
    bool clearQuoteError = false,
    bool clearCardTokenError = false,
    bool clearCardToken = false,
  }) {
    return CheckoutReadyState(
      summary: summary ?? this.summary,
      selectedPaymentMethod:
          selectedPaymentMethod ?? this.selectedPaymentMethod,
      isQuoting: isQuoting ?? this.isQuoting,
      isTokenizing: isTokenizing ?? this.isTokenizing,
      quoteError: clearQuoteError ? null : (quoteError ?? this.quoteError),
      cardTokenError:
          clearCardTokenError ? null : (cardTokenError ?? this.cardTokenError),
      cardToken: clearCardToken ? null : (cardToken ?? this.cardToken),
    );
  }

  @override
  List<Object?> get props => [
        summary,
        selectedPaymentMethod,
        isQuoting,
        isTokenizing,
        quoteError,
        cardTokenError,
        cardToken,
      ];
}

class CheckoutAlreadyEntitledState extends CheckoutState {
  final CheckoutSummary summary;

  const CheckoutAlreadyEntitledState({required this.summary});

  @override
  List<Object?> get props => [summary];
}

class CheckoutErrorState extends CheckoutState {
  final String message;

  const CheckoutErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}

class CheckoutPaymentRequestedState extends CheckoutState {
  final String tripId;
  final String paymentMethod;
  final String? couponCode;

  const CheckoutPaymentRequestedState({
    required this.tripId,
    required this.paymentMethod,
    this.couponCode,
  });

  @override
  List<Object?> get props => [tripId, paymentMethod, couponCode];
}

class CardReadyForPaymentState extends CheckoutState {
  final String tripId;
  final String cardToken;
  final String? paymentMethodId;
  final String? issuerId;
  final int installments;
  final String? couponCode;

  const CardReadyForPaymentState({
    required this.tripId,
    required this.cardToken,
    this.paymentMethodId,
    this.issuerId,
    this.installments = 1,
    this.couponCode,
  });

  @override
  List<Object?> get props => [
        tripId,
        cardToken,
        paymentMethodId,
        issuerId,
        installments,
        couponCode,
      ];
}

class CheckoutCancelledState extends CheckoutState {
  const CheckoutCancelledState();
}
