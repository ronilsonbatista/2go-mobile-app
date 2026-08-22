import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twogo_payments/twogo_payments.dart';
import 'package:twogo_planning/twogo_planning.dart';

import 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  final PaymentsRepository _paymentsRepository;
  final PostAuthIntentStorage _intentStorage;
  final CardTokenizer _cardTokenizer;

  CheckoutCubit({
    required PaymentsRepository paymentsRepository,
    required PostAuthIntentStorage intentStorage,
    CardTokenizer? cardTokenizer,
  })  : _paymentsRepository = paymentsRepository,
        _intentStorage = intentStorage,
        _cardTokenizer = cardTokenizer ?? NativeCardTokenizer(),
        super(const CheckoutInitialState());

  Future<void> loadCheckout(String tripId) async {
    emit(const CheckoutLoadingState());

    try {
      final summary = await _paymentsRepository.getCheckoutSummary(tripId);

      if (summary.alreadyUnlocked || summary.existingPurchaseStatus == 'PAID') {
        emit(CheckoutAlreadyEntitledState(summary: summary));
        return;
      }

      final defaultMethod = summary.supportedPaymentMethods.isNotEmpty
          ? summary.supportedPaymentMethods.first
          : 'PIX';

      emit(CheckoutReadyState(
        summary: summary,
        selectedPaymentMethod: defaultMethod,
      ));
    } catch (e) {
      emit(const CheckoutErrorState(
        message: 'Não foi possível carregar o resumo da compra.',
      ));
    }
  }

  Future<void> applyCoupon(String tripId, String couponCode) async {
    final currentState = state;
    if (currentState is! CheckoutReadyState) return;

    final trimmed = couponCode.trim().toUpperCase();
    if (trimmed.isEmpty) return;

    emit(currentState.copyWith(isQuoting: true, clearQuoteError: true));

    try {
      final updatedSummary = await _paymentsRepository.getCheckoutQuote(
        tripId,
        couponCode: trimmed,
      );

      emit(currentState.copyWith(
        summary: updatedSummary,
        isQuoting: false,
        clearQuoteError: true,
      ));
    } catch (e) {
      emit(currentState.copyWith(
        isQuoting: false,
        quoteError: 'Cupom inválido ou expirado.',
      ));
    }
  }

  Future<void> removeCoupon(String tripId) async {
    final currentState = state;
    if (currentState is! CheckoutReadyState) return;

    emit(currentState.copyWith(isQuoting: true, clearQuoteError: true));

    try {
      final updatedSummary = await _paymentsRepository.getCheckoutQuote(
        tripId,
        couponCode: null,
      );

      emit(currentState.copyWith(
        summary: updatedSummary,
        isQuoting: false,
        clearQuoteError: true,
      ));
    } catch (e) {
      emit(currentState.copyWith(
        isQuoting: false,
        quoteError: 'Erro ao remover cupom.',
      ));
    }
  }

  void selectPaymentMethod(String method) {
    final currentState = state;
    if (currentState is! CheckoutReadyState) return;

    emit(currentState.copyWith(
      selectedPaymentMethod: method,
      clearCardToken: true,
      clearCardTokenError: true,
    ));
  }

  Future<void> requestPayment({
    String publicKey = 'APP_USR-TEST-DEVELOPMENT-PUBLIC-KEY',
    int installments = 1,
  }) async {
    final currentState = state;
    if (currentState is! CheckoutReadyState) return;

    if (currentState.selectedPaymentMethod.toUpperCase() == 'CARD' ||
        currentState.selectedPaymentMethod.toUpperCase() == 'CREDIT_CARD') {
      if (publicKey.trim().isEmpty) {
        emit(currentState.copyWith(
          cardTokenError: 'Chave pública Mercado Pago não configurada.',
        ));
        return;
      }

      emit(currentState.copyWith(
        isTokenizing: true,
        clearCardTokenError: true,
      ));

      try {
        final result = await _cardTokenizer.tokenizeCard(
          publicKey: publicKey,
          installments: installments,
        );

        emit(CardReadyForPaymentState(
          tripId: currentState.summary.tripId,
          cardToken: result.cardToken,
          paymentMethodId: result.paymentMethodId,
          issuerId: result.issuerId,
          installments: result.installments,
          couponCode: currentState.summary.coupon?.code,
        ));
      } catch (e) {
        emit(currentState.copyWith(
          isTokenizing: false,
          cardTokenError: e.toString().replaceAll('Exception: ', ''),
        ));
      }
    } else {
      emit(CheckoutPaymentRequestedState(
        tripId: currentState.summary.tripId,
        paymentMethod: currentState.selectedPaymentMethod,
        couponCode: currentState.summary.coupon?.code,
      ));
    }
  }

  Future<void> cancelCheckout() async {
    await _intentStorage.saveIntent(PostAuthIntent.normal);
    emit(const CheckoutCancelledState());
  }
}
