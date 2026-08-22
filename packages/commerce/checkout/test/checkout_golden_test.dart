import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_checkout/twogo_checkout.dart';
import 'package:twogo_design_system/design_system.dart';
import 'package:twogo_payments/twogo_payments.dart';
import 'package:twogo_planning/twogo_planning.dart';
import 'package:twogo_storage/twogo_storage.dart';

class MockPaymentsRepoForGoldens implements PaymentsRepository {
  final CheckoutSummary summary;

  MockPaymentsRepoForGoldens(this.summary);

  @override
  Future<CheckoutSummary> getCheckoutSummary(String tripId) async => summary;

  @override
  Future<CheckoutSummary> getCheckoutQuote(
    String tripId, {
    String? couponCode,
  }) async {
    if (couponCode == 'INVALID') {
      throw Exception('Cupom inválido');
    }
    if (couponCode == 'PROMO10') {
      return CheckoutSummary(
        tripId: summary.tripId,
        alreadyUnlocked: false,
        productId: summary.productId,
        productType: summary.productType,
        productName: summary.productName,
        productDescription: summary.productDescription,
        pricing: const CheckoutPricing(
          originalAmount: 19.99,
          discountAmount: 10.0,
          finalAmount: 9.99,
          currency: 'BRL',
        ),
        coupon: const AppliedCoupon(
          code: 'PROMO10',
          applied: true,
          discountType: 'FIXED',
          discountValue: 10.0,
          description: 'Desconto de R\$ 10,00',
        ),
        supportedPaymentMethods: summary.supportedPaymentMethods,
      );
    }
    return summary;
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
    return CheckoutPaymentResult(
      purchaseId: 'pur_golden_123',
      status: 'PENDING',
      paymentMethod: paymentMethod,
      pixDetails: paymentMethod.toUpperCase() == 'PIX'
          ? const PixDetails(
              copyPaste: '00020126360014BR.GOV.BCB.PIX0114+5511999999999',
              qrCodeBase64: 'iVBORw0KGgoAAAANSU5EUgAAAAEAAAABCAYAAAAfFcSJ',
              expiresAt: '2026-08-22T00:00:00.000Z',
            )
          : null,
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
  group('Checkout Golden & UX Verification Tests', () {
    late InMemoryPostAuthIntentStorage intentStorage;

    setUp(() {
      intentStorage = InMemoryPostAuthIntentStorage();
    });

    const defaultSummary = CheckoutSummary(
      tripId: 'trip_paris_123',
      alreadyUnlocked: false,
      productId: 'prod_full_access',
      productType: 'ITINERARY_FULL_ACCESS',
      productName: 'Roteiro Completo Paris',
      productDescription: 'Acesso completo com mapas off-line e suporte VIP',
      pricing: CheckoutPricing(
        originalAmount: 19.99,
        discountAmount: 0.0,
        finalAmount: 19.99,
        currency: 'BRL',
      ),
      supportedPaymentMethods: ['PIX', 'CARD'],
    );

    testWidgets('checkout_loading_390x844', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          child: CheckoutPage(
            tripId: 'trip_paris_123',
            paymentsRepository: MockPaymentsRepoForGoldens(defaultSummary),
            intentStorage: intentStorage,
            storage: TwoGoStorage(),
            cardTokenizer: FakeCardTokenizer(),
          ),
          size: const Size(390, 844),
        ),
      );

      expect(find.text('Checkout Premium'), findsOneWidget);
    });

    testWidgets('checkout_summary_390x844', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          child: CheckoutPage(
            tripId: 'trip_paris_123',
            paymentsRepository: MockPaymentsRepoForGoldens(defaultSummary),
            intentStorage: intentStorage,
            storage: TwoGoStorage(),
            cardTokenizer: FakeCardTokenizer(),
          ),
          size: const Size(390, 844),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Roteiro Completo Paris'), findsOneWidget);
      expect(find.text('R\$ 19,99'), findsWidgets);
    });

    testWidgets('checkout_coupon_sheet_390x844', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          child: CheckoutPage(
            tripId: 'trip_paris_123',
            paymentsRepository: MockPaymentsRepoForGoldens(defaultSummary),
            intentStorage: intentStorage,
            storage: TwoGoStorage(),
            cardTokenizer: FakeCardTokenizer(),
          ),
          size: const Size(390, 844),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Cupom de Desconto'), findsOneWidget);
    });

    testWidgets('checkout_coupon_applied_390x844', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          child: CheckoutPage(
            tripId: 'trip_paris_123',
            paymentsRepository: MockPaymentsRepoForGoldens(defaultSummary),
            intentStorage: intentStorage,
            storage: TwoGoStorage(),
            cardTokenizer: FakeCardTokenizer(),
          ),
          size: const Size(390, 844),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TwoGoTextField),
        'PROMO10',
      );
      await tester.tap(find.text('Aplicar'));
      await tester.pumpAndSettle();

      expect(find.text('Cupom PROMO10 Aplicado!'), findsOneWidget);
      expect(find.text('R\$ 9,99'), findsWidgets);
    });

    testWidgets('checkout_coupon_error_390x844', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          child: CheckoutPage(
            tripId: 'trip_paris_123',
            paymentsRepository: MockPaymentsRepoForGoldens(defaultSummary),
            intentStorage: intentStorage,
            storage: TwoGoStorage(),
            cardTokenizer: FakeCardTokenizer(),
          ),
          size: const Size(390, 844),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TwoGoTextField),
        'INVALID',
      );
      await tester.tap(find.text('Aplicar'));
      await tester.pumpAndSettle();

      expect(find.text('Cupom inválido ou expirado.'), findsOneWidget);
    });

    testWidgets('checkout_payment_methods_390x844', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          child: CheckoutPage(
            tripId: 'trip_paris_123',
            paymentsRepository: MockPaymentsRepoForGoldens(defaultSummary),
            intentStorage: intentStorage,
            storage: TwoGoStorage(),
            cardTokenizer: FakeCardTokenizer(),
          ),
          size: const Size(390, 844),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('PIX'), findsOneWidget);
      expect(find.text('Cartão de Crédito'), findsOneWidget);
    });

    testWidgets('checkout_already_entitled_390x844', (tester) async {
      final entitledSummary = const CheckoutSummary(
        tripId: 'trip_paris_123',
        alreadyUnlocked: true,
        productId: 'prod_full_access',
        productType: 'ITINERARY_FULL_ACCESS',
        productName: 'Roteiro Completo Paris',
        pricing: CheckoutPricing(
          originalAmount: 19.99,
          discountAmount: 0.0,
          finalAmount: 19.99,
          currency: 'BRL',
        ),
        supportedPaymentMethods: ['PIX'],
      );

      await tester.pumpWidget(
        buildTestableWidget(
          child: CheckoutPage(
            tripId: 'trip_paris_123',
            paymentsRepository: MockPaymentsRepoForGoldens(entitledSummary),
            intentStorage: intentStorage,
            storage: TwoGoStorage(),
          ),
          size: const Size(390, 844),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Roteiro Já Desbloqueado!'), findsOneWidget);
    });
  });
}
