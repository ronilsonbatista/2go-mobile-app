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
  bool shouldThrowProcessCheckout = false;
  PixDetails? customPixDetails;

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

    if (shouldThrowProcessCheckout) {
      throw Exception('Network timeout before reaching server');
    }

    return CheckoutPaymentResult(
      purchaseId: 'pur_l2b_999',
      status: 'PENDING',
      paymentMethod: paymentMethod,
      pixDetails: paymentMethod.toUpperCase() == 'PIX'
          ? (customPixDetails ??
              const PixDetails(
                copyPaste: '00020126360014BR.GOV.BCB.PIX0114+5511999999999',
                qrCodeBase64: 'iVBORw0KGgoAAAANSU5EUgAAAAEAAAABCAYAAAAfFcSJ',
                expiresAt: '2026-08-22T00:00:00.000Z',
              ))
          : null,
    );
  }

  @override
  Future<PurchaseStatusResult> getPurchaseStatus(String purchaseId) async {
    getPurchaseStatusCallCount++;
    return PurchaseStatusResult(
      purchaseId: purchaseId,
      status: statusToReturn,
      pixDetails: statusToReturn == 'PENDING'
          ? (customPixDetails ??
              const PixDetails(
                copyPaste: '00020126360014BR.GOV.BCB.PIX0114+5511999999999',
                qrCodeBase64: 'iVBORw0KGgoAAAANSU5EUgAAAAEAAAABCAYAAAAfFcSJ',
                expiresAt: '2026-08-22T00:00:00.000Z',
              ))
          : null,
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

  group('Phase L2B.1 Comprehensive Payment Recovery & Idempotency Tests', () {
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

    test('1. PIX restart PENDING restores QR code & copyPaste directly from Core',
        () async {
      final repo = MockPaymentsRepoForL2B(defaultSummary);
      await storage.setString('checkout_purchase_id_trip_l2b_123', 'pur_l2b_999');

      final cubit = CheckoutPaymentCubit(
        paymentsRepository: repo,
        storage: storage,
      );

      await cubit.resumePendingPayment('trip_l2b_123');

      expect(cubit.state, isA<CheckoutPixPendingState>());
      final pixState = cubit.state as CheckoutPixPendingState;
      expect(pixState.purchaseId, 'pur_l2b_999');
      expect(pixState.copyPaste, contains('BR.GOV.BCB.PIX'));
      expect(pixState.qrCodeBase64, isNotNull);
      expect(repo.processCheckoutCallCount, 0); // Restored without new POST

      await cubit.close();
    });

    test('2. PIX restart PAID restores status PAID without creating new purchase',
        () async {
      final repo = MockPaymentsRepoForL2B(defaultSummary);
      repo.statusToReturn = 'PAID';
      await storage.setString('checkout_purchase_id_trip_l2b_123', 'pur_l2b_999');

      final cubit = CheckoutPaymentCubit(
        paymentsRepository: repo,
        storage: storage,
      );

      await cubit.resumePendingPayment('trip_l2b_123');

      expect(cubit.state, isA<PaymentConfirmedByCoreState>());
      final handoffIntent =
          await storage.getString('intent_hand_off_trip_l2b_123');
      expect(handoffIntent, 'PAYMENT_CONFIRMED');
      expect(repo.processCheckoutCallCount, 0);

      await cubit.close();
    });

    test('3. Idempotency Key is generated before POST and persisted', () async {
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
        '4. CARD payment submits token, clears token in memory, and zero token in storage',
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

      // Assert card token is NEVER persisted in storage
      final storedToken = await storage.getString('cardToken');
      expect(storedToken, isNull);

      await cubit.close();
    });

    test('5. 10x Rapid Double Tap executes only 1 POST call', () async {
      final repo = MockPaymentsRepoForL2B(defaultSummary);
      final cubit = CheckoutPaymentCubit(
        paymentsRepository: repo,
        storage: storage,
      );

      // Execute 10 rapid calls
      final futures = List.generate(
        10,
        (_) => cubit.executePayment(
          tripId: 'trip_l2b_123',
          paymentMethod: 'PIX',
        ),
      );

      await Future.wait(futures);

      expect(repo.processCheckoutCallCount, 1);

      await cubit.close();
    });

    test('6. CARD timeout before server clears idempotency key safely without token',
        () async {
      final repo = MockPaymentsRepoForL2B(defaultSummary);
      repo.shouldThrowProcessCheckout = true; // Request never reached server

      final cubit = CheckoutPaymentCubit(
        paymentsRepository: repo,
        storage: storage,
      );

      await cubit.executePayment(
        tripId: 'trip_l2b_123',
        paymentMethod: 'CARD',
        cardToken: 'mp_tok_transient_111',
      );

      expect(cubit.state, isA<CheckoutPaymentFailureState>());
      // Idempotency key for failed attempt is cleared so user can re-tokenize card
      final savedKey =
          await storage.getString('checkout_idempotency_op_trip_l2b_123');
      expect(savedKey, isNull);

      // Verify card token was not persisted
      final storedToken = await storage.getString('cardToken');
      expect(storedToken, isNull);

      await cubit.close();
    });

    test('7. Backgrounding pauses status polling and foreground resumes immediately',
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

      final countBeforePause = repo.getPurchaseStatusCallCount;
      cubit.pausePolling();

      // Wait 4 seconds while paused
      await Future<void>.delayed(const Duration(seconds: 4));
      expect(repo.getPurchaseStatusCallCount, countBeforePause); // 0 calls while paused

      cubit.resumePolling();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(repo.getPurchaseStatusCallCount, greaterThan(countBeforePause));

      await cubit.close();
    });

    test('8. Process death after PAID preserves handoff intent for Phase M',
        () async {
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
      await cubit.close();

      // Simulate app restart and check storage persistence
      final intent = await storage.getString('intent_hand_off_trip_l2b_123');
      expect(intent, 'PAYMENT_CONFIRMED');
    });
  });
}
