import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_checkout/twogo_checkout.dart';
import 'package:twogo_payments/twogo_payments.dart';
import 'package:twogo_planning/twogo_planning.dart';

class FakePaymentsRepository implements PaymentsRepository {
  CheckoutSummary? nextSummary;
  CheckoutSummary? nextQuote;
  bool shouldThrowSummary = false;
  bool shouldThrowQuote = false;
  String? lastQuoteCouponCode;

  @override
  Future<CheckoutSummary> getCheckoutSummary(String tripId) async {
    if (shouldThrowSummary) throw Exception('Network error');
    return nextSummary ??
        CheckoutSummary(
          tripId: tripId,
          alreadyUnlocked: false,
          productId: 'prod_01',
          productType: 'ITINERARY_FULL_ACCESS',
          productName: 'Roteiro Premium Teste',
          productDescription: 'Descrição teste',
          pricing: const CheckoutPricing(
            originalAmount: 100.0,
            discountAmount: 0.0,
            finalAmount: 100.0,
            currency: 'BRL',
          ),
          supportedPaymentMethods: const ['PIX', 'CARD'],
        );
  }

  @override
  Future<CheckoutSummary> getCheckoutQuote(
    String tripId, {
    String? couponCode,
  }) async {
    lastQuoteCouponCode = couponCode;
    if (shouldThrowQuote) throw Exception('Invalid coupon');
    return nextQuote ??
        CheckoutSummary(
          tripId: tripId,
          alreadyUnlocked: false,
          productId: 'prod_01',
          productType: 'ITINERARY_FULL_ACCESS',
          productName: 'Roteiro Premium Teste',
          pricing: CheckoutPricing(
            originalAmount: 100.0,
            discountAmount: couponCode != null ? 10.0 : 0.0,
            finalAmount: couponCode != null ? 90.0 : 100.0,
            currency: 'BRL',
          ),
          coupon: couponCode != null
              ? AppliedCoupon(
                  code: couponCode,
                  applied: true,
                  discountType: 'FIXED',
                  discountValue: 10.0,
                )
              : null,
          supportedPaymentMethods: const ['PIX', 'CARD'],
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

void main() {
  group('CheckoutCubit Tests', () {
    late FakePaymentsRepository repository;
    late InMemoryPostAuthIntentStorage intentStorage;
    late CheckoutCubit cubit;

    setUp(() {
      repository = FakePaymentsRepository();
      intentStorage = InMemoryPostAuthIntentStorage();
      cubit = CheckoutCubit(
        paymentsRepository: repository,
        intentStorage: intentStorage,
      );
    });

    tearDown(() {
      cubit.close();
    });

    test('loadCheckout emits ready state with exact values from Core',
        () async {
      await cubit.loadCheckout('trip_123');

      expect(cubit.state, isA<CheckoutReadyState>());
      final ready = cubit.state as CheckoutReadyState;
      expect(ready.summary.pricing.originalAmount, 100.0);
      expect(ready.summary.pricing.discountAmount, 0.0);
      expect(ready.summary.pricing.finalAmount, 100.0);
      expect(ready.selectedPaymentMethod, 'PIX');
    });

    test(
        'loadCheckout emits CheckoutAlreadyEntitledState if alreadyUnlocked is true',
        () async {
      repository.nextSummary = const CheckoutSummary(
        tripId: 'trip_123',
        alreadyUnlocked: true,
        productId: 'prod_01',
        productType: 'ITINERARY_FULL_ACCESS',
        productName: 'Roteiro Premium',
        pricing: CheckoutPricing(
          originalAmount: 19.99,
          discountAmount: 0,
          finalAmount: 19.99,
          currency: 'BRL',
        ),
        supportedPaymentMethods: ['PIX'],
      );

      await cubit.loadCheckout('trip_123');
      expect(cubit.state, isA<CheckoutAlreadyEntitledState>());
    });

    test('applyCoupon fetches quote from Core and updates pricing', () async {
      await cubit.loadCheckout('trip_123');

      await cubit.applyCoupon('trip_123', 'WALL10');

      expect(repository.lastQuoteCouponCode, 'WALL10');
      expect(cubit.state, isA<CheckoutReadyState>());
      final ready = cubit.state as CheckoutReadyState;
      expect(ready.summary.pricing.finalAmount, 90.0);
      expect(ready.summary.coupon?.code, 'WALL10');
    });

    test('applyCoupon with invalid code sets quoteError without breaking state',
        () async {
      await cubit.loadCheckout('trip_123');
      repository.shouldThrowQuote = true;

      await cubit.applyCoupon('trip_123', 'INVALID');

      expect(cubit.state, isA<CheckoutReadyState>());
      final ready = cubit.state as CheckoutReadyState;
      expect(ready.quoteError, 'Cupom inválido ou expirado.');
    });

    test('removeCoupon calls quote with null code and resets price', () async {
      await cubit.loadCheckout('trip_123');
      await cubit.applyCoupon('trip_123', 'WALL10');
      await cubit.removeCoupon('trip_123');

      expect(repository.lastQuoteCouponCode, null);
      final ready = cubit.state as CheckoutReadyState;
      expect(ready.summary.pricing.finalAmount, 100.0);
      expect(ready.summary.coupon, null);
    });

    test('selectPaymentMethod updates selectedPaymentMethod in state',
        () async {
      await cubit.loadCheckout('trip_123');
      cubit.selectPaymentMethod('CARD');

      final ready = cubit.state as CheckoutReadyState;
      expect(ready.selectedPaymentMethod, 'CARD');
    });

    test('requestPayment emits CheckoutPaymentRequestedState without money',
        () async {
      await cubit.loadCheckout('trip_123');
      cubit.selectPaymentMethod('PIX');
      await cubit.requestPayment();

      expect(cubit.state, isA<CheckoutPaymentRequestedState>());
      final requested = cubit.state as CheckoutPaymentRequestedState;
      expect(requested.tripId, 'trip_123');
      expect(requested.paymentMethod, 'PIX');
      expect(requested.couponCode, null);
    });

    test(
        'cancelCheckout clears resumeCheckout intent and emits CheckoutCancelledState',
        () async {
      await intentStorage.saveIntent(
        PostAuthIntent(
          type: PostAuthIntentType.resumeCheckout,
          tripId: 'trip_123',
          createdAt: DateTime.now(),
        ),
      );

      await cubit.cancelCheckout();

      final saved = await intentStorage.readIntent();
      expect(saved, isNull);
      expect(cubit.state, isA<CheckoutCancelledState>());
    });
  });
}
