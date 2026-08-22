import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twogo_storage/twogo_storage.dart';
import 'package:twogo_payments/twogo_payments.dart';
import 'package:twogo_trips/trips.dart';
import 'paid_trip_handoff_state.dart';

class PaidTripHandoffCubit extends Cubit<PaidTripHandoffState> {
  final PaymentsRepository _paymentsRepository;
  final TripsRepository _tripsRepository;
  final TwoGoStorage _storage;

  PaidTripHandoffCubit({
    required PaymentsRepository paymentsRepository,
    required TripsRepository tripsRepository,
    required TwoGoStorage storage,
  })  : _paymentsRepository = paymentsRepository,
        _tripsRepository = tripsRepository,
        _storage = storage,
        super(const PaidTripHandoffInitialState());

  Future<void> reconcileAndUnlockTrip({
    required String tripId,
    required String purchaseId,
  }) async {
    emit(PaidTripHandoffReconcilingState(tripId: tripId, purchaseId: purchaseId));

    try {
      // 1. Reconcile purchase status with Core API
      final statusResult = await _paymentsRepository.getPurchaseStatus(purchaseId);
      final status = statusResult.status.toUpperCase();

      if (status == 'PAID') {
        // 2. Fetch authoritative authenticated Trip from Core
        final trip = await _tripsRepository.getTripById(tripId);

        // 3. Perform idempotent cleanup ONLY after entitlement confirmed and Trip fetched
        await performCleanup(tripId);

        emit(PaidTripHandoffSuccessState(
          tripId: tripId,
          trip: trip,
        ));
      } else if (status == 'PENDING') {
        emit(PaidTripHandoffPendingState(
          tripId: tripId,
          purchaseId: purchaseId,
          message: 'Seu pagamento ainda está em processamento.',
        ));
      } else {
        // CANCELLED, EXPIRED, REFUNDED, CHARGEBACK
        await performCleanup(tripId);
        emit(PaidTripHandoffFailureState(
          errorMessage: 'O pagamento não foi concluído com sucesso ($status).',
          canRetryPayment: true,
        ));
      }
    } catch (e) {
      final message = e.toString().replaceAll('Exception: ', '');
      // On network failure, DO NOT clean up intents! Enable user to retry.
      emit(PaidTripHandoffFailureState(
        errorMessage: 'Não foi possível conectar ao servidor: $message',
        canRetryReconciliation: true,
      ));
    }
  }

  Future<void> performCleanup(String tripId) async {
    await _storage.remove('intent_hand_off_$tripId');
    await _storage.remove('active_paid_handoff_trip_id');
    await _storage.remove('active_paid_handoff_purchase_id');
    await _storage.remove('checkout_idempotency_op_$tripId');
    await _storage.remove('checkout_purchase_id_$tripId');
    await _storage.remove('post_auth_intent');
    await _storage.remove('guest_journey_transient_data');
  }
}
