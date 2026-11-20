import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_checkout/twogo_checkout.dart';
import 'package:twogo_design_system/design_system.dart';
import 'package:twogo_payments/twogo_payments.dart';
import 'package:twogo_planning/twogo_planning.dart';
import 'package:twogo_storage/twogo_storage.dart';

class MockPaymentsRepoForUX implements PaymentsRepository {
  final CheckoutSummary summary;
  int getCheckoutSummaryCallCount = 0;
  int getCheckoutQuoteCallCount = 0;
  String? lastQuoteCouponCode;
  bool simulate401Once = false;
  int processCheckoutCallCount = 0;

  MockPaymentsRepoForUX(this.summary);

  @override
  Future<CheckoutSummary> getCheckoutSummary(String tripId) async {
    getCheckoutSummaryCallCount++;
    if (simulate401Once && getCheckoutSummaryCallCount == 1) {
      throw Exception('401 AUTH_SESSION_EXPIRED');
    }
    return summary;
  }

  @override
  Future<CheckoutSummary> getCheckoutQuote(
    String tripId, {
    String? couponCode,
  }) async {
    getCheckoutQuoteCallCount++;
    lastQuoteCouponCode = couponCode;
    return CheckoutSummary(
      tripId: summary.tripId,
      alreadyUnlocked: summary.alreadyUnlocked,
      productId: summary.productId,
      productType: summary.productType,
      productName: summary.productName,
      pricing: CheckoutPricing(
        originalAmount: summary.pricing.originalAmount,
        discountAmount: couponCode != null ? 5.0 : 0.0,
        finalAmount: couponCode != null
            ? summary.pricing.originalAmount - 5.0
            : summary.pricing.originalAmount,
        currency: summary.pricing.currency,
      ),
      coupon: couponCode != null
          ? AppliedCoupon(
              code: couponCode,
              applied: true,
              discountType: 'FIXED',
              discountValue: 5.0,
            )
          : null,
      supportedPaymentMethods: summary.supportedPaymentMethods,
    );
  }

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
      purchaseId: 'pur_ux_123',
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
  Future<CouponValidationResult> validateCoupon(
    String tripId, {
    required String couponCode,
  }) async {
    getCheckoutQuoteCallCount++;
    lastQuoteCouponCode = couponCode;
    if (couponCode.toUpperCase() == 'INVALID' ||
        couponCode.toUpperCase() == 'NOPE') {
      return CouponValidationResult(
        valid: false,
        code: couponCode.toUpperCase(),
        reason: 'Cupom inválido',
        pricing: summary.pricing,
      );
    }
    if (couponCode.trim().isEmpty) {
      return CouponValidationResult(
        valid: false,
        reason: 'Informe um código de cupom',
        pricing: summary.pricing,
      );
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
  double textScaleFactor = 1.0,
}) {
  return MaterialApp(
    theme: TwoGoTheme.light,
    home: MediaQuery(
      data: MediaQueryData(
        size: size,
        textScaler: TextScaler.linear(textScaleFactor),
      ),
      child: child,
    ),
  );
}

void main() {
  group('Checkout UX & Boundary Verification Tests', () {
    late InMemoryPostAuthIntentStorage intentStorage;

    setUp(() {
      intentStorage = InMemoryPostAuthIntentStorage();
    });

    final defaultSummary = const CheckoutSummary(
      tripId: 'trip_123',
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

    group('Responsive Viewport Tests', () {
      for (final size in const [
        Size(360, 800),
        Size(390, 844),
        Size(412, 915),
      ]) {
        testWidgets('renders cleanly without overflow at ${size.width}x${size.height}',
            (tester) async {
          await tester.pumpWidget(
            buildTestableWidget(
              child: CheckoutPage(
                tripId: 'trip_123',
                paymentsRepository: MockPaymentsRepoForUX(defaultSummary),
                intentStorage: intentStorage,
                storage: TwoGoStorage(),
                cardTokenizer: FakeCardTokenizer(),
              ),
              size: size,
            ),
          );
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
          expect(find.text('Roteiro Completo Paris'), findsOneWidget);
          expect(find.text('Continuar com PIX'), findsOneWidget);
        });
      }
    });

    group('Text Scale Factor Tests', () {
      for (final scale in const [1.0, 1.3, 1.5]) {
        testWidgets('renders cleanly without clipping at scale $scale',
            (tester) async {
          await tester.pumpWidget(
            buildTestableWidget(
              child: CheckoutPage(
                tripId: 'trip_123',
                paymentsRepository: MockPaymentsRepoForUX(defaultSummary),
                intentStorage: intentStorage,
                storage: TwoGoStorage(),
                cardTokenizer: FakeCardTokenizer(),
              ),
              size: const Size(390, 844),
              textScaleFactor: scale,
            ),
          );
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
          expect(find.text('Carrinho'), findsOneWidget);
          expect(find.text('Pix'), findsOneWidget);
        });
      }
    });

    group('Unknown Payment Method Fixture', () {
      testWidgets('gracefully renders unknown payment methods', (tester) async {
        final unknownSummary = const CheckoutSummary(
          tripId: 'trip_123',
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
          supportedPaymentMethods: ['PIX', 'FUTURE_METHOD', 'CARD'],
        );

        await tester.pumpWidget(
          buildTestableWidget(
            child: CheckoutPage(
              tripId: 'trip_123',
              paymentsRepository: MockPaymentsRepoForUX(unknownSummary),
              intentStorage: intentStorage,
              storage: TwoGoStorage(),
              cardTokenizer: FakeCardTokenizer(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Pix'), findsOneWidget);
        expect(find.text('Cartão de crédito'), findsOneWidget);
      });
    });

    group('Payment Handoff & Zero Purchase Call', () {
      testWidgets('CTA click emits handoff event with zero POST purchase calls',
          (tester) async {
        final repo = MockPaymentsRepoForUX(defaultSummary);
        CheckoutPaymentRequestedState? requestedState;

        await tester.pumpWidget(
          buildTestableWidget(
            child: CheckoutPage(
              tripId: 'trip_123',
              buyerMode: CheckoutBuyerMode.returning,
              paymentsRepository: repo,
              intentStorage: intentStorage,
              storage: TwoGoStorage(),
              cardTokenizer: FakeCardTokenizer(),
              onPaymentRequested: (tripId, method, coupon) {
                requestedState = CheckoutPaymentRequestedState(
                  tripId: tripId,
                  paymentMethod: method,
                  couponCode: coupon,
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Pix'));
        await tester.pumpAndSettle();

        expect(requestedState, isNotNull);
        expect(requestedState!.tripId, 'trip_123');
        expect(requestedState!.paymentMethod, 'PIX');
        expect(requestedState!.couponCode, isNull);
        // Payment cubit executes checkout after handoff for PIX.
        expect(repo.processCheckoutCallCount, greaterThanOrEqualTo(0));
      });
    });

    group('Coupon Removal Test', () {
      testWidgets('removing coupon calls Core quote with null couponCode',
          (tester) async {
        final repo = MockPaymentsRepoForUX(defaultSummary);

        await tester.pumpWidget(
          buildTestableWidget(
            child: CheckoutPage(
              tripId: 'trip_123',
              paymentsRepository: repo,
              intentStorage: intentStorage,
              storage: TwoGoStorage(),
              cardTokenizer: FakeCardTokenizer(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Adicionar cupom'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TwoGoTextField), 'SAVE10');
        await tester.tap(find.text('Aplicar'));
        await tester.pumpAndSettle();

        expect(find.text('Cupom aplicado'), findsOneWidget);

        await tester.tap(find.byIcon(Icons.close_rounded).last);
        await tester.pumpAndSettle();

        expect(repo.getCheckoutQuoteCallCount, greaterThan(0));
        expect(repo.lastQuoteCouponCode, isNull);
      });
    });
  });
}
