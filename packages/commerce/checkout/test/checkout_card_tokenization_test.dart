import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_checkout/twogo_checkout.dart';
import 'package:twogo_design_system/design_system.dart';
import 'package:twogo_payments/twogo_payments.dart';
import 'package:twogo_planning/twogo_planning.dart';

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
  Future<List<ProductEntity>> getActiveProducts() async => [];

  @override
  Future<List<PurchaseEntity>> getMyPurchases() async => [];

  @override
  Future<PurchaseEntity> createMockPurchase({
    required String productId,
    String? tripId,
  }) async {
    processCheckoutCallCount++;
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
      await tester.pumpWidget(
        buildTestableWidget(
          child: CheckoutPage(
            tripId: 'trip_card_123',
            paymentsRepository: MockPaymentsRepoForCardTests(defaultSummaryWithCard),
            intentStorage: intentStorage,
            cardTokenizer: FakeCardTokenizer(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final cardTileFinder = find.text('Cartão de Crédito');
      await tester.ensureVisible(cardTileFinder);
      await tester.pumpAndSettle();
      await tester.tap(cardTileFinder);
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/checkout_card_entry_390x844.png'),
      );
    });

    testWidgets('golden checkout_card_error_390x844', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          child: CheckoutPage(
            tripId: 'trip_card_123',
            paymentsRepository: MockPaymentsRepoForCardTests(defaultSummaryWithCard),
            intentStorage: intentStorage,
            cardTokenizer: FakeCardTokenizer(
              exceptionToThrow: Exception('Número do cartão inválido.'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final cardTileFinder = find.text('Cartão de Crédito');
      await tester.ensureVisible(cardTileFinder);
      await tester.pumpAndSettle();
      await tester.tap(cardTileFinder);
      await tester.pumpAndSettle();

      final ctaFinder = find.text('Continuar com Cartão de Crédito');
      await tester.ensureVisible(ctaFinder);
      await tester.pumpAndSettle();
      await tester.tap(ctaFinder);
      await tester.pumpAndSettle();

      expect(find.text('Número do cartão inválido.'), findsOneWidget);

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/checkout_card_error_390x844.png'),
      );
    });
  });
}
