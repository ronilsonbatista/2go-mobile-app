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

  /// Soft cupom via Core `POST .../coupons/validate` (HTTP 200 + valid flag).
  Future<void> applyCoupon(String tripId, String couponCode) async {
    final currentState = state;
    if (currentState is! CheckoutReadyState) return;

    final trimmed = couponCode.trim().toUpperCase();
    if (trimmed.isEmpty) return;

    emit(currentState.copyWith(
      isQuoting: true,
      clearQuoteError: true,
      couponJustApplied: false,
    ));

    try {
      final validation = await _paymentsRepository.validateCoupon(
        tripId,
        couponCode: trimmed,
      );

      if (!validation.valid) {
        emit(currentState.copyWith(
          isQuoting: false,
          quoteError: validation.reason ?? 'Cupom inválido',
          couponJustApplied: false,
        ));
        return;
      }

      final pricing = validation.pricing ?? currentState.summary.pricing;
      final updated = currentState.summary.copyWith(
        pricing: pricing,
        coupon: validation.coupon ??
            AppliedCoupon(
              code: validation.code ?? trimmed,
              applied: true,
              discountType: 'FIXED',
              discountValue: pricing.discountAmount,
            ),
      );

      emit(currentState.copyWith(
        summary: updated,
        isQuoting: false,
        clearQuoteError: true,
        couponJustApplied: true,
      ));
    } catch (e) {
      emit(currentState.copyWith(
        isQuoting: false,
        quoteError: 'Cupom inválido',
        couponJustApplied: false,
      ));
    }
  }

  Future<void> removeCoupon(String tripId) async {
    final currentState = state;
    if (currentState is! CheckoutReadyState) return;

    emit(currentState.copyWith(
      isQuoting: true,
      clearQuoteError: true,
      couponJustApplied: false,
    ));

    try {
      final updatedSummary = await _paymentsRepository.getCheckoutQuote(
        tripId,
        couponCode: null,
      );

      emit(currentState.copyWith(
        summary: updatedSummary,
        isQuoting: false,
        clearQuoteError: true,
        couponJustApplied: false,
      ));
    } catch (e) {
      emit(currentState.copyWith(
        isQuoting: false,
        quoteError: 'Erro ao remover cupom.',
        couponJustApplied: false,
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
      couponJustApplied: false,
    ));
  }

  /// Prefetch card intent stub before tokenization (Core PR #4).
  Future<void> prepareCardIntent({String? publicKey}) async {
    final currentState = state;
    if (currentState is! CheckoutReadyState) return;

    emit(currentState.copyWith(isTokenizing: true, clearCardTokenError: true));

    try {
      final intent = await _paymentsRepository.createCardIntent(
        tripId: currentState.summary.tripId,
        couponCode: currentState.summary.coupon?.code,
      );
      emit(currentState.copyWith(
        isTokenizing: false,
        cardIntent: intent,
      ));
    } catch (e) {
      emit(currentState.copyWith(
        isTokenizing: false,
        cardTokenError: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> requestPayment({
    String publicKey = 'APP_USR-TEST-DEVELOPMENT-PUBLIC-KEY',
    String? cpf,
    int installments = 1,
  }) async {
    final currentState = state;
    if (currentState is! CheckoutReadyState) return;

    final method = currentState.selectedPaymentMethod.toUpperCase();

    if (method == 'CARD' || method == 'CREDIT_CARD') {
      if (publicKey.trim().isEmpty &&
          (currentState.cardIntent?.publicKey?.isEmpty ?? true)) {
        // Layout/dev stub: allow fake tokenizer without MP public key.
      }

      emit(currentState.copyWith(
        isTokenizing: true,
        clearCardTokenError: true,
      ));

      try {
        // Ensure card-intent was requested (Core flow).
        if (currentState.cardIntent == null) {
          await _paymentsRepository.createCardIntent(
            tripId: currentState.summary.tripId,
            couponCode: currentState.summary.coupon?.code,
            installments: installments,
          );
        }

        final effectiveKey =
            currentState.cardIntent?.publicKey?.trim().isNotEmpty == true
                ? currentState.cardIntent!.publicKey!
                : publicKey;

        final result = await _cardTokenizer.tokenizeCard(
          publicKey: effectiveKey.isEmpty
              ? 'APP_USR-TEST-DEVELOPMENT-PUBLIC-KEY'
              : effectiveKey,
          cpf: cpf,
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
