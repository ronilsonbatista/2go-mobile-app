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
          expect(find.text('Checkout Premium'), findsOneWidget);
          expect(find.text('PIX'), findsOneWidget);
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
        expect(find.text('PIX'), findsOneWidget);
        expect(find.text('FUTURE_METHOD'), findsOneWidget);
        expect(find.text('Cartão de Crédito'), findsOneWidget);
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

        await tester.tap(find.text('Continuar com PIX'));
        await tester.pumpAndSettle();

        expect(requestedState, isNotNull);
        expect(requestedState!.tripId, 'trip_123');
        expect(requestedState!.paymentMethod, 'PIX');
        expect(requestedState!.couponCode, isNull);
        expect(repo.processCheckoutCallCount, 0);
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

        await tester.enterText(find.byType(TwoGoTextField), 'SAVE10');
        await tester.tap(find.text('Aplicar'));
        await tester.pumpAndSettle();

        expect(repo.lastQuoteCouponCode, 'SAVE10');

        await tester.tap(find.text('Remover'));
        await tester.pumpAndSettle();

        expect(repo.lastQuoteCouponCode, isNull);
      });
    });
  });
}
