import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twogo_storage/twogo_storage.dart';
import 'package:twogo_checkout/twogo_checkout.dart';
import 'package:twogo_payments/twogo_payments.dart';

class MockPaymentsRepoForL2B implements PaymentsRepository {
  final CheckoutSummary summary;
  int processCheckoutCallCount = 0;
  int getPurchaseStatusCallCount = 0;
  String? lastIdempotencyKey;
  String? lastPaymentMethod;
  String? lastCardToken;
  String statusToReturn = 'PENDING';

  MockPaymentsRepoForL2B(this.summary);

  @override
  Future<CheckoutSummary> getCheckoutSummary(String tripId) async => summary;

  @override
  Future<CheckoutSummary> getCheckoutQuote(
    String tripId, {
    String? couponCode,
  }) async =>
      summary;

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
    lastIdempotencyKey = idempotencyKey;
    lastPaymentMethod = paymentMethod;
    lastCardToken = cardToken;

    return CheckoutPaymentResult(
      purchaseId: 'pur_l2b_999',
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
    getPurchaseStatusCallCount++;
    return PurchaseStatusResult(
      purchaseId: purchaseId,
      status: statusToReturn,
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
  }) async =>
      throw UnimplementedError();

  @override
  Future<PurchaseEntity> confirmMockPayment(String purchaseId) async =>
      throw UnimplementedError();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase L2B Real Payment & Idempotency Tests', () {
    late TwoGoStorage storage;
    const defaultSummary = CheckoutSummary(
      tripId: 'trip_l2b_123',
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

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      storage = TwoGoStorage();
    });

    test('PIX Creation emits CheckoutPixPendingState and does NOT mean PAID',
        () async {
      final repo = MockPaymentsRepoForL2B(defaultSummary);
      final cubit = CheckoutPaymentCubit(
        paymentsRepository: repo,
        storage: storage,
      );

      await cubit.executePayment(
        tripId: 'trip_l2b_123',
        paymentMethod: 'PIX',
      );

      expect(cubit.state, isA<CheckoutPixPendingState>());
      final pixState = cubit.state as CheckoutPixPendingState;
      expect(pixState.purchaseId, 'pur_l2b_999');
      expect(pixState.copyPaste, contains('BR.GOV.BCB.PIX'));

      // Assert creation alone is NOT PaymentConfirmedByCoreState
      expect(cubit.state, isNot(isA<PaymentConfirmedByCoreState>()));

      await cubit.close();
    });

    test('Idempotency Key is generated before POST and persisted', () async {
      final repo = MockPaymentsRepoForL2B(defaultSummary);
      final cubit = CheckoutPaymentCubit(
        paymentsRepository: repo,
        storage: storage,
      );

      await cubit.executePayment(
        tripId: 'trip_l2b_123',
        paymentMethod: 'PIX',
      );

      expect(repo.lastIdempotencyKey, isNotNull);
      expect(repo.lastIdempotencyKey, startsWith('idempotency_'));

      // Re-executing same logical payment reuses the exact same idempotency key
      final firstKey = repo.lastIdempotencyKey;
      final secondCubit = CheckoutPaymentCubit(
        paymentsRepository: repo,
        storage: storage,
      );
      await secondCubit.executePayment(
        tripId: 'trip_l2b_123',
        paymentMethod: 'PIX',
      );

      expect(repo.lastIdempotencyKey, firstKey);

      await cubit.close();
      await secondCubit.close();
    });

    test(
        'CARD payment submits token, clears token, and enters awaiting confirmation',
        () async {
      final repo = MockPaymentsRepoForL2B(defaultSummary);
      final cubit = CheckoutPaymentCubit(
        paymentsRepository: repo,
        storage: storage,
      );

      await cubit.executePayment(
        tripId: 'trip_l2b_123',
        paymentMethod: 'CARD',
        cardToken: 'mp_tok_secret_999',
      );

      expect(repo.lastCardToken, 'mp_tok_secret_999');
      expect(cubit.state, isA<CheckoutCardAwaitingConfirmationState>());

      // Assert card token is NOT persisted in storage
      final storedToken = await storage.getString('cardToken');
      expect(storedToken, isNull);

      await cubit.close();
    });

    test('Core status PAID emits PaymentConfirmedByCoreState', () async {
      final repo = MockPaymentsRepoForL2B(defaultSummary);
      repo.statusToReturn = 'PAID';

      final cubit = CheckoutPaymentCubit(
        paymentsRepository: repo,
        storage: storage,
      );

      await cubit.executePayment(
        tripId: 'trip_l2b_123',
        paymentMethod: 'PIX',
      );

      await cubit.resumePendingPayment('trip_l2b_123');

      expect(cubit.state, isA<PaymentConfirmedByCoreState>());
      final confirmed = cubit.state as PaymentConfirmedByCoreState;
      expect(confirmed.purchaseId, 'pur_l2b_999');
      expect(confirmed.tripId, 'trip_l2b_123');

      await cubit.close();
    });
  });
}
