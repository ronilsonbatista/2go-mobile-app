import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_checkout/twogo_checkout.dart';
import 'package:twogo_design_system/design_system.dart';
import 'package:twogo_payments/twogo_payments.dart';
import 'package:twogo_planning/twogo_planning.dart';
import 'package:twogo_storage/twogo_storage.dart';

class MockPaymentsRepoForUI implements PaymentsRepository {
  final CheckoutSummary summary;

  MockPaymentsRepoForUI(this.summary);

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
    return CheckoutPaymentResult(
      purchaseId: 'pur_test_123',
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
  group('CheckoutPage UI Tests', () {
    late InMemoryPostAuthIntentStorage intentStorage;

    setUp(() {
      intentStorage = InMemoryPostAuthIntentStorage();
    });

    testWidgets('renders loading state cleanly', (tester) async {
      const summary = CheckoutSummary(
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

      await tester.pumpWidget(
        buildTestableWidget(
          child: CheckoutPage(
            tripId: 'trip_123',
            paymentsRepository: MockPaymentsRepoForUI(summary),
            intentStorage: intentStorage,
            storage: TwoGoStorage(),
            cardTokenizer: FakeCardTokenizer(),
          ),
        ),
      );

      expect(find.text('Carrinho'), findsOneWidget);
      await tester.pumpAndSettle();

      expect(find.text('Roteiro Completo Paris'), findsOneWidget);
      expect(find.text('R\$ 19,99'), findsWidgets);
    });

    testWidgets('renders payment methods list from Core', (tester) async {
      const summary = CheckoutSummary(
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

      await tester.pumpWidget(
        buildTestableWidget(
          child: CheckoutPage(
            tripId: 'trip_123',
            paymentsRepository: MockPaymentsRepoForUI(summary),
            intentStorage: intentStorage,
            storage: TwoGoStorage(),
            cardTokenizer: FakeCardTokenizer(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pix'), findsOneWidget);
      expect(find.text('Cartão de crédito'), findsOneWidget);
      expect(find.text('Continuar com PIX'), findsOneWidget);
    });

    testWidgets('renders already entitled state correctly', (tester) async {
      const summary = CheckoutSummary(
        tripId: 'trip_123',
        alreadyUnlocked: true,
        productId: 'prod_01',
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
            tripId: 'trip_123',
            paymentsRepository: MockPaymentsRepoForUI(summary),
            intentStorage: intentStorage,
            storage: TwoGoStorage(),
            cardTokenizer: FakeCardTokenizer(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Roteiro Já Desbloqueado!'), findsOneWidget);
      expect(find.text('Acessar Roteiro'), findsOneWidget);
    });
  });
}
