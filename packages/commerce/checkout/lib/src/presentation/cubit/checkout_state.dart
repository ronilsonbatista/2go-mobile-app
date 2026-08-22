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
  final String? quoteError;

  const CheckoutReadyState({
    required this.summary,
    required this.selectedPaymentMethod,
    this.isQuoting = false,
    this.quoteError,
  });

  CheckoutReadyState copyWith({
    CheckoutSummary? summary,
    String? selectedPaymentMethod,
    bool? isQuoting,
    String? quoteError,
    bool clearQuoteError = false,
  }) {
    return CheckoutReadyState(
      summary: summary ?? this.summary,
      selectedPaymentMethod:
          selectedPaymentMethod ?? this.selectedPaymentMethod,
      isQuoting: isQuoting ?? this.isQuoting,
      quoteError: clearQuoteError ? null : (quoteError ?? this.quoteError),
    );
  }

  @override
  List<Object?> get props => [
        summary,
        selectedPaymentMethod,
        isQuoting,
        quoteError,
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

class CheckoutCancelledState extends CheckoutState {
  const CheckoutCancelledState();
}
