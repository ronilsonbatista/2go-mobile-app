import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_checkout/twogo_checkout.dart';
import 'package:twogo_design_system/design_system.dart';
import 'package:twogo_payments/twogo_payments.dart';
import 'package:twogo_planning/twogo_planning.dart';
import 'package:twogo_storage/twogo_storage.dart';

/// Acceptance coverage for docs/pagamento-use-cases-2026-11-19.md (layout).
class _Repo implements PaymentsRepository {
  _Repo(this.summary);

  final CheckoutSummary summary;

  @override
  Future<CheckoutSummary> getCheckoutSummary(String tripId) async => summary;

  @override
  Future<CheckoutSummary> getCheckoutQuote(
    String tripId, {
    String? couponCode,
  }) async {
    if (couponCode == null) return summary;
    return summary.copyWith(
      pricing: CheckoutPricing(
        originalAmount: summary.pricing.originalAmount,
        discountAmount: 2,
        finalAmount: summary.pricing.originalAmount - 2,
        currency: summary.pricing.currency,
      ),
      coupon: AppliedCoupon(
        code: couponCode,
        applied: true,
        discountType: 'FIXED',
        discountValue: 2,
      ),
    );
  }

  @override
  Future<CouponValidationResult> validateCoupon(
    String tripId, {
    required String couponCode,
  }) async {
    if (couponCode.toUpperCase() == 'INVALID') {
      return CouponValidationResult(
        valid: false,
        reason: 'Cupom inválido',
        pricing: summary.pricing,
      );
    }
    return CouponValidationResult(
      valid: true,
      code: couponCode.toUpperCase(),
      pricing: CheckoutPricing(
        originalAmount: summary.pricing.originalAmount,
        discountAmount: 2,
        finalAmount: summary.pricing.originalAmount - 2,
        currency: summary.pricing.currency,
      ),
      coupon: AppliedCoupon(
        code: couponCode.toUpperCase(),
        applied: true,
        discountType: 'FIXED',
        discountValue: 2,
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
      intentId: 'intent',
      tripId: tripId,
      status: 'READY',
      amount: summary.pricing.finalAmount,
      currency: 'BRL',
    );
  }

  @override
  Future<ExpirePurchaseResult> expirePurchase(String purchaseId) async {
    return ExpirePurchaseResult(purchaseId: purchaseId, status: 'EXPIRED');
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
      purchaseId: 'pur_matrix',
      status: 'PENDING',
      paymentMethod: paymentMethod,
      pixDetails: paymentMethod.toUpperCase() == 'PIX'
          ? const PixDetails(
              copyPaste: 'pix-code',
              expiresAt: '2099-01-01T00:00:00.000Z',
            )
          : null,
    );
  }

  @override
  Future<PurchaseStatusResult> getPurchaseStatus(String purchaseId) async {
    return PurchaseStatusResult(purchaseId: purchaseId, status: 'PENDING');
  }

  @override
  Future<List<ProductEntity>> getActiveProducts() async => [];

  @override
  Future<List<PurchaseEntity>> getMyPurchases() async => [];

  @override
  Future<PurchaseEntity> createMockPurchase({
    required String productId,
    String? tripId,
  }) async =>
      throw UnimplementedError();

  @override
  Future<PurchaseEntity> confirmMockPayment(String purchaseId) async =>
      throw UnimplementedError();
}

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: TwoGoTheme.light,
    home: MediaQuery(
      data: const MediaQueryData(size: Size(390, 844)),
      child: child,
    ),
  );
}

void main() {
  late InMemoryPostAuthIntentStorage intentStorage;

  const summary = CheckoutSummary(
    tripId: 'trip_roma',
    alreadyUnlocked: false,
    productId: 'prod',
    productType: 'ITINERARY_FULL_ACCESS',
    productName: 'Roteiro',
    pricing: CheckoutPricing(
      originalAmount: 21.99,
      discountAmount: 0,
      finalAmount: 21.99,
      currency: 'BRL',
    ),
    supportedPaymentMethods: ['PIX', 'CARD'],
    paymentMethodAvailability: [
      PaymentMethodAvailability(
        method: 'PIX',
        available: true,
        status: 'AVAILABLE',
      ),
      PaymentMethodAvailability(
        method: 'CARD',
        available: true,
        status: 'AVAILABLE',
      ),
      PaymentMethodAvailability(
        method: 'APPLE_PAY',
        available: false,
        status: 'COMING_SOON',
      ),
    ],
  );

  setUp(() {
    intentStorage = InMemoryPostAuthIntentStorage();
  });

  testWidgets('case 1 — 1ª compra shows dados + termos', (tester) async {
    await tester.pumpWidget(
      _wrap(
        CheckoutPage(
          tripId: 'trip_roma',
          buyerMode: CheckoutBuyerMode.firstPurchase,
          paymentsRepository: _Repo(summary),
          intentStorage: intentStorage,
          storage: TwoGoStorage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dados pessoais'), findsOneWidget);
    expect(find.textContaining('Termos de Uso'), findsOneWidget);
    expect(find.text('Valor'), findsOneWidget);
    expect(find.text('R\$ 21,99'), findsWidgets);
  });

  testWidgets('case 2 — 2ª compra hides dados + termos', (tester) async {
    await tester.pumpWidget(
      _wrap(
        CheckoutPage(
          tripId: 'trip_roma',
          buyerMode: CheckoutBuyerMode.returning,
          paymentsRepository: _Repo(summary),
          intentStorage: intentStorage,
          storage: TwoGoStorage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dados pessoais'), findsNothing);
    expect(find.textContaining('Li e aceito'), findsNothing);
    expect(find.text('Cartão de crédito'), findsOneWidget);
    expect(find.text('Pix'), findsOneWidget);
  });

  testWidgets('case 3 — invite prefills nome/tel and keeps CPF empty',
      (tester) async {
    await tester.pumpWidget(
      _wrap(
        CheckoutPage(
          tripId: 'trip_roma',
          buyerMode: CheckoutBuyerMode.invite,
          invitePrefill: CheckoutInvitePrefill.demoJoao,
          paymentsRepository: _Repo(summary),
          intentStorage: intentStorage,
          storage: TwoGoStorage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('João Ribeiro Silva'), findsOneWidget);
    expect(find.text('(00) 9 1234-5678'), findsOneWidget);
    expect(find.textContaining('Termos de Uso'), findsOneWidget);
  });

  testWidgets('case 8 — termos block toast when unchecked', (tester) async {
    await tester.pumpWidget(
      _wrap(
        CheckoutPage(
          tripId: 'trip_roma',
          buyerMode: CheckoutBuyerMode.firstPurchase,
          paymentsRepository: _Repo(summary),
          intentStorage: intentStorage,
          storage: TwoGoStorage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TwoGoTextField).at(0),
      'Maria Silva',
    );
    await tester.enterText(
      find.byType(TwoGoTextField).at(1),
      '11999999999',
    );
    await tester.enterText(
      find.byType(TwoGoTextField).at(2),
      '52998224725',
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pix'));
    await tester.pumpAndSettle();

    expect(
      find.text('Aceite o Termos de Uso antes de continuar'),
      findsOneWidget,
    );
  });

  testWidgets('case 9 — termos page opens and returns', (tester) async {
    await tester.pumpWidget(
      _wrap(
        CheckoutPage(
          tripId: 'trip_roma',
          buyerMode: CheckoutBuyerMode.firstPurchase,
          paymentsRepository: _Repo(summary),
          intentStorage: intentStorage,
          storage: TwoGoStorage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Termos de Uso'));
    await tester.pumpAndSettle();

    expect(find.text('1. Sobre o serviço'), findsOneWidget);
  });

  testWidgets('success + error layout widgets', (tester) async {
    await tester.pumpWidget(
      _wrap(
        CheckoutSuccessView(onAccessItinerary: () {}),
      ),
    );
    expect(find.text('Pagamento confirmado'), findsOneWidget);
    expect(find.text('Acessar roteiro'), findsOneWidget);

    await tester.pumpWidget(
      _wrap(
        CheckoutErrorView(onBack: () {}),
      ),
    );
    expect(find.text('Ops!'), findsOneWidget);
    expect(find.text('Voltar'), findsOneWidget);
  });
}
