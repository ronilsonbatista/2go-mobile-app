import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_checkout/twogo_checkout.dart';
import 'package:twogo_design_system/design_system.dart';
import 'package:twogo_payments/twogo_payments.dart';
import 'package:twogo_planning/twogo_planning.dart';

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
          ),
        ),
      );

      expect(find.text('Checkout Premium'), findsOneWidget);
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
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('PIX'), findsOneWidget);
      expect(find.text('Cartão de Crédito'), findsOneWidget);
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
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Roteiro Já Desbloqueado!'), findsOneWidget);
      expect(find.text('Acessar Roteiro'), findsOneWidget);
    });
  });
}
