import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twogo_storage/twogo_storage.dart';
import 'package:twogo_payments/twogo_payments.dart';
import 'checkout_payment_state.dart';

class CheckoutPaymentCubit extends Cubit<CheckoutPaymentState> {
  final PaymentsRepository _paymentsRepository;
  final TwoGoStorage _storage;
  Timer? _pollingTimer;
  Timer? _countdownTimer;
  bool _isPaused = false;
  bool _isExecuting = false;
  String? _activePurchaseId;
  String? _activeTripId;

  CheckoutPaymentCubit({
    required PaymentsRepository paymentsRepository,
    required TwoGoStorage storage,
  })  : _paymentsRepository = paymentsRepository,
        _storage = storage,
        super(const CheckoutPaymentInitialState());

  Future<void> executePayment({
    required String tripId,
    required String paymentMethod,
    String? couponCode,
    String? cardToken,
    int installments = 1,
  }) async {
    // 0. Synchronous double-tap protection against rapid re-entries
    if (_isExecuting ||
        state is CheckoutPaymentProcessingState ||
        state is CheckoutPixPendingState ||
        state is CheckoutCardAwaitingConfirmationState) {
      return;
    }

    _isExecuting = true;
    _activeTripId = tripId;

    try {
      // 1. Retrieve or generate persisted Idempotency Key BEFORE POST
      final storageKey = 'checkout_idempotency_op_$tripId';
      var idempotencyKey = await _storage.getString(storageKey);
      if (idempotencyKey == null || idempotencyKey.isEmpty) {
        idempotencyKey = 'idempotency_${DateTime.now().millisecondsSinceEpoch}_${tripId.hashCode.abs()}';
        await _storage.setString(storageKey, idempotencyKey);
      }

      emit(CheckoutPaymentProcessingState(
        tripId: tripId,
        paymentMethod: paymentMethod,
        idempotencyKey: idempotencyKey,
      ));

      final result = await _paymentsRepository.processCheckoutPayment(
        tripId: tripId,
        paymentMethod: paymentMethod,
        couponCode: couponCode,
        cardToken: cardToken,
        installments: installments,
        idempotencyKey: idempotencyKey,
      );

      _activePurchaseId = result.purchaseId;
      await _storage.setString('checkout_purchase_id_$tripId', result.purchaseId);

      if (result.paymentMethod.toUpperCase() == 'PIX') {
        final expiresAtStr = result.pixDetails?.expiresAt;
        int remainingSecs = 900; // default 15 mins
        if (expiresAtStr != null) {
          final expiry = DateTime.tryParse(expiresAtStr);
          if (expiry != null) {
            remainingSecs = expiry.difference(DateTime.now()).inSeconds;
            if (remainingSecs < 0) remainingSecs = 0;
          }
        }

        emit(CheckoutPixPendingState(
          purchaseId: result.purchaseId,
          tripId: tripId,
          copyPaste: result.pixDetails?.copyPaste,
          qrCodeBase64: result.pixDetails?.qrCodeBase64,
          expiresAt: result.pixDetails?.expiresAt,
          remainingSeconds: remainingSecs,
        ));

        _startCountdownTimer(remainingSecs);
        _startStatusPolling(result.purchaseId, tripId);
      } else {
        emit(CheckoutCardAwaitingConfirmationState(
          purchaseId: result.purchaseId,
          tripId: tripId,
        ));
        _startStatusPolling(result.purchaseId, tripId);
      }
    } catch (e) {
      final message = e.toString().replaceAll('Exception: ', '');

      // Handle active payment exists conflict gracefully
      if (message.contains('Existe uma cobrança ativa pendente')) {
        await resumePendingPayment(tripId);
        return;
      }

      // Handle card timeout / local network failure
      if (paymentMethod.toUpperCase() == 'CARD' && _activePurchaseId == null) {
        final storageKey = 'checkout_idempotency_op_$tripId';
        final purchaseId = await _storage.getString('checkout_purchase_id_$tripId');
        if (purchaseId != null && purchaseId.isNotEmpty) {
          _activePurchaseId = purchaseId;
          await _checkStatusOnce(purchaseId, tripId);
          if (state is PaymentConfirmedByCoreState ||
              state is CheckoutCardAwaitingConfirmationState) {
            return;
          }
        }
        // If request did NOT reach Core, clear old operation key so user can re-tokenize card
        await _storage.remove(storageKey);
      }

      emit(CheckoutPaymentFailureState(errorMessage: message));
    } finally {
      _isExecuting = false;
    }
  }

  Future<void> resumePendingPayment(String tripId) async {
    _activeTripId = tripId;
    final purchaseId = await _storage.getString('checkout_purchase_id_$tripId');
    if (purchaseId == null || purchaseId.isEmpty) return;

    _activePurchaseId = purchaseId;
    await _checkStatusOnce(purchaseId, tripId);
  }

  void _startStatusPolling(String purchaseId, String tripId) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (_isPaused) return;
      await _checkStatusOnce(purchaseId, tripId);
    });
  }

  Future<void> _checkStatusOnce(String purchaseId, String tripId) async {
    try {
      final statusResult = await _paymentsRepository.getPurchaseStatus(purchaseId);
      final status = statusResult.status.toUpperCase();

      if (status == 'PAID') {
        _stopTimers();
        await _storage.setString('intent_hand_off_$tripId', 'PAYMENT_CONFIRMED');
        await _storage.remove('checkout_idempotency_op_$tripId');

        emit(PaymentConfirmedByCoreState(
          purchaseId: purchaseId,
          tripId: tripId,
        ));
      } else if (status == 'PENDING' && statusResult.pixDetails != null) {
        final expiresAtStr = statusResult.pixDetails?.expiresAt;
        int remainingSecs = 900;
        if (expiresAtStr != null) {
          final expiry = DateTime.tryParse(expiresAtStr);
          if (expiry != null) {
            remainingSecs = expiry.difference(DateTime.now()).inSeconds;
            if (remainingSecs < 0) remainingSecs = 0;
          }
        }

        emit(CheckoutPixPendingState(
          purchaseId: purchaseId,
          tripId: tripId,
          copyPaste: statusResult.pixDetails?.copyPaste,
          qrCodeBase64: statusResult.pixDetails?.qrCodeBase64,
          expiresAt: statusResult.pixDetails?.expiresAt,
          remainingSeconds: remainingSecs,
        ));

        _startCountdownTimer(remainingSecs);
        _startStatusPolling(purchaseId, tripId);
      } else if (status == 'EXPIRED') {
        _stopTimers();
        await _storage.remove('checkout_idempotency_op_$tripId');
        await _storage.remove('checkout_purchase_id_$tripId');
        emit(CheckoutPaymentExpiredState(purchaseId: purchaseId));
      } else if (status == 'CANCELLED' || status == 'REFUNDED' || status == 'CHARGEBACK') {
        _stopTimers();
        await _storage.remove('checkout_idempotency_op_$tripId');
        await _storage.remove('checkout_purchase_id_$tripId');
        emit(const CheckoutPaymentRejectedState(
          errorMessage: 'Pagamento recusado ou cancelado pelo provedor.',
        ));
      }
    } catch (_) {
      // Ignore temporary status check error during polling
    }
  }

  void _startCountdownTimer(int initialSeconds) {
    _countdownTimer?.cancel();
    var secondsLeft = initialSeconds;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPaused) return;
      secondsLeft--;
      if (secondsLeft <= 0) {
        timer.cancel();
      }
      final currentState = state;
      if (currentState is CheckoutPixPendingState) {
        emit(CheckoutPixPendingState(
          purchaseId: currentState.purchaseId,
          tripId: currentState.tripId,
          copyPaste: currentState.copyPaste,
          qrCodeBase64: currentState.qrCodeBase64,
          expiresAt: currentState.expiresAt,
          remainingSeconds: secondsLeft < 0 ? 0 : secondsLeft,
        ));
      }
    });
  }

  void pausePolling() {
    _isPaused = true;
  }

  void resumePolling() {
    _isPaused = false;
    if (_activePurchaseId != null && _activeTripId != null) {
      _checkStatusOnce(_activePurchaseId!, _activeTripId!);
    }
  }

  void _stopTimers() {
    _pollingTimer?.cancel();
    _countdownTimer?.cancel();
    _pollingTimer = null;
    _countdownTimer = null;
  }

  @override
  Future<void> close() {
    _stopTimers();
    return super.close();
  }
}
