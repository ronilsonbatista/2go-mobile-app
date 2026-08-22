import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twogo_storage/twogo_storage.dart';
import 'package:twogo_checkout/twogo_checkout.dart';
import 'package:twogo_payments/twogo_payments.dart';
import 'package:twogo_trips/trips.dart';

class MockPaymentsRepoForPhaseM implements PaymentsRepository {
  int processCheckoutCallCount = 0;
  int getPurchaseStatusCallCount = 0;
  String statusToReturn = 'PAID';
  bool shouldThrowStatusError = false;

  @override
  Future<CheckoutSummary> getCheckoutSummary(String tripId) async =>
      throw UnimplementedError();

  @override
  Future<CheckoutSummary> getCheckoutQuote(
    String tripId, {
    String? couponCode,
  }) async =>
      throw UnimplementedError();

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
    throw UnimplementedError('Phase M must never call processCheckoutPayment');
  }

  @override
  Future<PurchaseStatusResult> getPurchaseStatus(String purchaseId) async {
    getPurchaseStatusCallCount++;
    if (shouldThrowStatusError) {
      throw Exception('Server unavailable');
    }
    return PurchaseStatusResult(
      purchaseId: purchaseId,
      status: statusToReturn,
      paidAt: statusToReturn == 'PAID' ? '2026-08-22T00:00:00.000Z' : null,
      premiumUnlocked: statusToReturn == 'PAID',
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

class MockTripsRepoForPhaseM implements TripsRepository {
  int getTripByIdCallCount = 0;
  TripEntity? tripToReturn;

  @override
  Future<List<TripEntity>> getMyTrips() async => [];

  @override
  Future<TripEntity> getTripById(String id) async {
    getTripByIdCallCount++;
    return tripToReturn ??
        TripEntity(
          id: id,
          userId: 'usr_m_123',
          title: 'Viagem Paris',
          destination: 'Paris, França',
          days: const [],
        );
  }

  @override
  Future<TripEntity> createTrip({
    required String title,
    required String destination,
    DateTime? startDate,
    DateTime? endDate,
  }) async =>
      throw UnimplementedError();

  @override
  Future<TripEntity> updateTrip(TripEntity trip) async =>
      throw UnimplementedError();

  @override
  Future<void> deleteTrip(String id) async => throw UnimplementedError();

  @override
  Future<TripDayEntity> addTripDay(String tripId, int dayNumber,
          {String? title}) async =>
      throw UnimplementedError();

  @override
  Future<ItineraryItemEntity> addItineraryItem(
          String dayId, ItineraryItemEntity item) async =>
      throw UnimplementedError();

  @override
  Future<ItineraryItemEntity> updateItineraryItem(ItineraryItemEntity item) async =>
      throw UnimplementedError();

  @override
  Future<void> deleteItineraryItem(String itemId) async =>
      throw UnimplementedError();

  @override
  Future<void> reorderItineraryItem(String itemId, int newOrder) async =>
      throw UnimplementedError();

  @override
  Future<TripEntity> generateAiItinerary(
          String tripId, Map<String, dynamic> preferences) async =>
      throw UnimplementedError();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase M Paid Trip Handoff & Entitlement Tests', () {
    late TwoGoStorage storage;
    late MockPaymentsRepoForPhaseM paymentsRepo;
    late MockTripsRepoForPhaseM tripsRepo;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      storage = TwoGoStorage();
      paymentsRepo = MockPaymentsRepoForPhaseM();
      tripsRepo = MockTripsRepoForPhaseM();
    });

    test('1. Happy Path: PAYMENT_CONFIRMED reconciles to PAID and activates Full Trip',
        () async {
      await storage.setString('intent_hand_off_trip_m_100', 'PAYMENT_CONFIRMED');
      await storage.setString('active_paid_handoff_trip_id', 'trip_m_100');
      await storage.setString('active_paid_handoff_purchase_id', 'pur_m_100');

      final cubit = PaidTripHandoffCubit(
        paymentsRepository: paymentsRepo,
        tripsRepository: tripsRepo,
        storage: storage,
      );

      await cubit.reconcileAndUnlockTrip(
        tripId: 'trip_m_100',
        purchaseId: 'pur_m_100',
      );

      expect(cubit.state, isA<PaidTripHandoffSuccessState>());
      final successState = cubit.state as PaidTripHandoffSuccessState;
      expect(successState.trip.id, 'trip_m_100');

      // Assert zero POST calls to processCheckoutPayment during Phase M
      expect(paymentsRepo.processCheckoutCallCount, 0);

      // Assert handoff intent storage cleanup after success
      final handoffIntent =
          await storage.getString('active_paid_handoff_trip_id');
      expect(handoffIntent, isNull);

      await cubit.close();
    });

    test('2. Core PENDING status keeps user in pending state without unlocking',
        () async {
      paymentsRepo.statusToReturn = 'PENDING';

      final cubit = PaidTripHandoffCubit(
        paymentsRepository: paymentsRepo,
        tripsRepository: tripsRepo,
        storage: storage,
      );

      await cubit.reconcileAndUnlockTrip(
        tripId: 'trip_m_100',
        purchaseId: 'pur_m_100',
      );

      expect(cubit.state, isA<PaidTripHandoffPendingState>());
      expect(tripsRepo.getTripByIdCallCount, 0); // Trip is NOT fetched when pending

      await cubit.close();
    });

    test('3. Network failure retains intent storage for retry', () async {
      paymentsRepo.shouldThrowStatusError = true;
      await storage.setString('active_paid_handoff_trip_id', 'trip_m_100');

      final cubit = PaidTripHandoffCubit(
        paymentsRepository: paymentsRepo,
        tripsRepository: tripsRepo,
        storage: storage,
      );

      await cubit.reconcileAndUnlockTrip(
        tripId: 'trip_m_100',
        purchaseId: 'pur_m_100',
      );

      expect(cubit.state, isA<PaidTripHandoffFailureState>());
      final failState = cubit.state as PaidTripHandoffFailureState;
      expect(failState.canRetryReconciliation, isTrue);

      // Assert intent is PRESERVED on network error
      final preservedIntent =
          await storage.getString('active_paid_handoff_trip_id');
      expect(preservedIntent, 'trip_m_100');

      await cubit.close();
    });

    test('4. CANCELLED / EXPIRED status performs cleanup and emits failure',
        () async {
      paymentsRepo.statusToReturn = 'CANCELLED';
      await storage.setString('active_paid_handoff_trip_id', 'trip_m_100');

      final cubit = PaidTripHandoffCubit(
        paymentsRepository: paymentsRepo,
        tripsRepository: tripsRepo,
        storage: storage,
      );

      await cubit.reconcileAndUnlockTrip(
        tripId: 'trip_m_100',
        purchaseId: 'pur_m_100',
      );

      expect(cubit.state, isA<PaidTripHandoffFailureState>());

      // Assert stale intent is cleaned up
      final handoff = await storage.getString('active_paid_handoff_trip_id');
      expect(handoff, isNull);

      await cubit.close();
    });

    test('5. Zero Payment POST call assertion during Phase M', () async {
      final cubit = PaidTripHandoffCubit(
        paymentsRepository: paymentsRepo,
        tripsRepository: tripsRepo,
        storage: storage,
      );

      await cubit.reconcileAndUnlockTrip(
        tripId: 'trip_m_100',
        purchaseId: 'pur_m_100',
      );

      expect(paymentsRepo.processCheckoutCallCount, 0);

      await cubit.close();
    });
  });
}
