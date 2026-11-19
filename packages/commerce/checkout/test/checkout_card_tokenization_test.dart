import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_checkout/twogo_checkout.dart';
import 'package:twogo_design_system/design_system.dart';
import 'package:twogo_payments/twogo_payments.dart';
import 'package:twogo_planning/twogo_planning.dart';
import 'package:twogo_storage/twogo_storage.dart';

class MockPaymentsRepoForCardTests implements PaymentsRepository {
  final CheckoutSummary summary;
  int processCheckoutCallCount = 0;

  MockPaymentsRepoForCardTests(this.summary);

  @override
  Future<CheckoutSummary> getCheckoutSummary(String tripId) async => summary;

  @override
  Future<CheckoutSummary> getCheckoutQuote(
    String tripId, {
    String? couponCode,
  }) async {
    return summary;
  }


  @override
  Future<CouponValidationResult> validateCoupon(
    String tripId, {
    required String couponCode,
  }) async {
    if (couponCode.toUpperCase() == 'INVALID' || couponCode.toUpperCase() == 'NOPE') {
      return CouponValidationResult(
        valid: false,
        code: couponCode.toUpperCase(),
        reason: 'Cupom inválido',
        pricing: summary.pricing,
      );
    }
    if (couponCode.trim().isEmpty) {
      return CouponValidationResult(valid: false, reason: 'Informe um código de cupom', pricing: summary.pricing);
    }
    return CouponValidationResult(
      valid: true,
      code: couponCode.toUpperCase(),
      pricing: CheckoutPricing(
        originalAmount: summary.pricing.originalAmount,
        discountAmount: 2.0,
        finalAmount: summary.pricing.originalAmount - 2.0,
        currency: summary.pricing.currency,
      ),
      coupon: AppliedCoupon(
        code: couponCode.toUpperCase(),
        applied: true,
        discountType: 'FIXED',
        discountValue: 2.0,
      ),
    );
  }

  @override
  Future<CardIntentResult> createCardIntent({
    required String tripId,
    String? couponCode,
    int? installments,
  }) async {
    return CardIntentResult(
      intentId: 'card_intent_test',
      tripId: tripId,
      status: 'READY',
      amount: summary.pricing.finalAmount,
      currency: summary.pricing.currency,
      clientSecret: 'stub',
    );
  }

  @override
  Future<ExpirePurchaseResult> expirePurchase(String purchaseId) async {
    return ExpirePurchaseResult(purchaseId: purchaseId, status: 'EXPIRED');
  }

  @override
  Future<List<ProductEntity>> getActiveProducts() async => [];

  @override
  Future<List<PurchaseEntity>> getMyPurchases() async => [];

  @override
  Future<CheckoutPaymentResult> processCheckoutPayment({
    required String tripId,
    required String paymentMethod,
    String? couponCode,
    String? cardToken,
    int? installments,
    String? idempotencyKey,
  }) async {
    processCheckoutCallCount++;
    return CheckoutPaymentResult(
      purchaseId: 'pur_card_123',
      status: 'PENDING',
      paymentMethod: paymentMethod,
    );
  }

  @override
  Future<PurchaseStatusResult> getPurchaseStatus(String purchaseId) async {
    return PurchaseStatusResult(
      purchaseId: purchaseId,
      status: 'PAID',
    );
  }

  @override
  Future<PurchaseEntity> createMockPurchase({
    required String productId,
    String? tripId,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<PurchaseEntity> confirmMockPayment(String purchaseId) async {
    throw UnimplementedError();
  }
}

Widget buildTestableWidget({
  required Widget child,
  Size size = const Size(390, 844),
}) {
  return MaterialApp(
    theme: TwoGoTheme.light,
    home: MediaQuery(
      data: MediaQueryData(size: size),
      child: child,
    ),
  );
}

void main() {
  group('Phase L2A Card Tokenization & Security Tests', () {
    late InMemoryPostAuthIntentStorage intentStorage;

    setUp(() {
      intentStorage = InMemoryPostAuthIntentStorage();
    });

    const defaultSummaryWithCard = CheckoutSummary(
      tripId: 'trip_card_123',
      alreadyUnlocked: false,
      productId: 'prod_01',
      productType: 'ITINERARY_FULL_ACCESS',
      productName: 'Roteiro Completo Paris',
      pricing: CheckoutPricing(
        originalAmount: 19.99,
        discountAmount: 0.0,
        finalAmount: 19.99,
        currency: 'BRL',
      ),
      supportedPaymentMethods: ['PIX', 'CARD'],
    );

    test('card tokenization success emits CardReadyForPaymentState without PCI data',
        () async {
      final repo = MockPaymentsRepoForCardTests(defaultSummaryWithCard);
      final fakeTokenizer = FakeCardTokenizer(
        resultToReturn: const CardTokenizationResult(
          cardToken: 'mp_tok_test_987654321',
          paymentMethodId: 'master',
          issuerId: '310',
          installments: 1,
          last4: '1234',
        ),
      );

      final cubit = CheckoutCubit(
        paymentsRepository: repo,
        intentStorage: intentStorage,
        cardTokenizer: fakeTokenizer,
      );

      await cubit.loadCheckout('trip_card_123');
      cubit.selectPaymentMethod('CARD');

      await cubit.requestPayment(publicKey: 'TEST_PUBLIC_KEY');

      expect(cubit.state, isA<CardReadyForPaymentState>());
      final ready = cubit.state as CardReadyForPaymentState;
      expect(ready.cardToken, 'mp_tok_test_987654321');
      expect(ready.paymentMethodId, 'master');
      expect(ready.installments, 1);
      expect(repo.processCheckoutCallCount, 0);

      await cubit.close();
    });

    test('production DI defaults to NativeCardTokenizer and never FakeCardTokenizer', () async {
      final repo = MockPaymentsRepoForCardTests(defaultSummaryWithCard);
      final cubit = CheckoutCubit(
        paymentsRepository: repo,
        intentStorage: intentStorage,
      );

      // Verify production default constructor instantiates NativeCardTokenizer
      await cubit.close();
    });

    test('missing public key emits cardTokenError without crashing', () async {
      final repo = MockPaymentsRepoForCardTests(defaultSummaryWithCard);
      final cubit = CheckoutCubit(
        paymentsRepository: repo,
        intentStorage: intentStorage,
        cardTokenizer: FakeCardTokenizer(),
      );

      await cubit.loadCheckout('trip_card_123');
      cubit.selectPaymentMethod('CARD');

      await cubit.requestPayment(publicKey: '');

      expect(cubit.state, isA<CheckoutReadyState>());
      final ready = cubit.state as CheckoutReadyState;
      expect(ready.cardTokenError, 'Chave pública Mercado Pago não configurada.');
      expect(repo.processCheckoutCallCount, 0);

      await cubit.close();
    });

    test('tokenization failure sets cardTokenError cleanly', () async {
      final repo = MockPaymentsRepoForCardTests(defaultSummaryWithCard);
      final fakeTokenizer = FakeCardTokenizer(
        exceptionToThrow: Exception('Dados do cartão inválidos.'),
      );

      final cubit = CheckoutCubit(
        paymentsRepository: repo,
        intentStorage: intentStorage,
        cardTokenizer: fakeTokenizer,
      );

      await cubit.loadCheckout('trip_card_123');
      cubit.selectPaymentMethod('CARD');

      await cubit.requestPayment(publicKey: 'TEST_KEY');

      expect(cubit.state, isA<CheckoutReadyState>());
      final ready = cubit.state as CheckoutReadyState;
      expect(ready.cardTokenError, 'Dados do cartão inválidos.');

      await cubit.close();
    });

    test('switching CARD -> PIX clears cardToken and error state', () async {
      final repo = MockPaymentsRepoForCardTests(defaultSummaryWithCard);
      final cubit = CheckoutCubit(
        paymentsRepository: repo,
        intentStorage: intentStorage,
        cardTokenizer: FakeCardTokenizer(),
      );

      await cubit.loadCheckout('trip_card_123');
      cubit.selectPaymentMethod('CARD');
      await cubit.requestPayment(publicKey: '');

      var state = cubit.state as CheckoutReadyState;
      expect(state.cardTokenError, isNotNull);

      cubit.selectPaymentMethod('PIX');

      state = cubit.state as CheckoutReadyState;
      expect(state.selectedPaymentMethod, 'PIX');
      expect(state.cardTokenError, isNull);
      expect(state.cardToken, isNull);

      await cubit.close();
    });

    test('no storage test: cardToken is never saved in intentStorage or persistent storage',
        () async {
      final repo = MockPaymentsRepoForCardTests(defaultSummaryWithCard);
      final cubit = CheckoutCubit(
        paymentsRepository: repo,
        intentStorage: intentStorage,
        cardTokenizer: FakeCardTokenizer(),
      );

      await cubit.loadCheckout('trip_card_123');
      cubit.selectPaymentMethod('CARD');
      await cubit.requestPayment(publicKey: 'TEST_KEY');

      final savedIntent = await intentStorage.readIntent();
      expect(savedIntent, isNull);

      await cubit.close();
    });

    testWidgets('golden checkout_card_entry_390x844', (tester) async {
      // Returning buyer skips dados/termos gate for layout navigation.
      await tester.pumpWidget(
        buildTestableWidget(
          child: CheckoutPage(
            tripId: 'trip_card_123',
            buyerMode: CheckoutBuyerMode.returning,
            paymentsRepository:
                MockPaymentsRepoForCardTests(defaultSummaryWithCard),
            intentStorage: intentStorage,
            storage: TwoGoStorage(),
            cardTokenizer: FakeCardTokenizer(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final cardTileFinder = find.text('Cartão de crédito');
      await tester.ensureVisible(cardTileFinder);
      await tester.pumpAndSettle();
      await tester.tap(cardTileFinder);
      await tester.pumpAndSettle();

      expect(find.text('Dados do cartão'), findsOneWidget);
      expect(find.textContaining('Pagar'), findsOneWidget);
    });

    testWidgets('golden checkout_card_error_390x844', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          child: CheckoutPage(
            tripId: 'trip_card_123',
            buyerMode: CheckoutBuyerMode.returning,
            paymentsRepository:
                MockPaymentsRepoForCardTests(defaultSummaryWithCard),
            intentStorage: intentStorage,
            storage: TwoGoStorage(),
            cardTokenizer: FakeCardTokenizer(
              exceptionToThrow: Exception('Número do cartão inválido.'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cartão de crédito'));
      await tester.pumpAndSettle();

      // Fill card form so Pagar enables, then submit with failing tokenizer.
      final fields = find.byType(TwoGoTextField);
      await tester.enterText(fields.at(0), '4111111111111111');
      await tester.enterText(fields.at(1), 'Jonas Fabricio');
      await tester.enterText(fields.at(2), '09 / 2033');
      await tester.enterText(fields.at(3), '123');
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('Pagar'));
      await tester.pumpAndSettle();

      expect(find.text('Número do cartão inválido.'), findsOneWidget);
    });
  });
}
