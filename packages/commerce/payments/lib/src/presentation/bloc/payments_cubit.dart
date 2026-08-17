import 'package:flutter/foundation.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/purchase_entity.dart';
import '../../domain/repositories/payments_repository.dart';

enum PaymentsStatus { initial, loading, loaded, error }

class PaymentsState {
  final PaymentsStatus status;
  final List<ProductEntity> products;
  final List<PurchaseEntity> purchases;
  final String? errorMessage;

  const PaymentsState({
    required this.status,
    this.products = const [],
    this.purchases = const [],
    this.errorMessage,
  });

  factory PaymentsState.initial() =>
      const PaymentsState(status: PaymentsStatus.initial);
  factory PaymentsState.loading() =>
      const PaymentsState(status: PaymentsStatus.loading);
  factory PaymentsState.loaded(
    List<ProductEntity> products,
    List<PurchaseEntity> purchases,
  ) => PaymentsState(
    status: PaymentsStatus.loaded,
    products: products,
    purchases: purchases,
  );
  factory PaymentsState.error(String message) =>
      PaymentsState(status: PaymentsStatus.error, errorMessage: message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentsState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          listEquals(products, other.products) &&
          listEquals(purchases, other.purchases) &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode =>
      status.hashCode ^
      products.hashCode ^
      purchases.hashCode ^
      errorMessage.hashCode;
}

class PaymentsCubit extends ValueNotifier<PaymentsState> {
  final PaymentsRepository _paymentsRepository;

  PaymentsCubit({required PaymentsRepository paymentsRepository})
    : _paymentsRepository = paymentsRepository,
      super(PaymentsState.initial());

  Future<void> loadProductsAndPurchases() async {
    value = PaymentsState.loading();
    try {
      final products = await _paymentsRepository.getActiveProducts();
      final purchases = await _paymentsRepository.getMyPurchases();
      value = PaymentsState.loaded(products, purchases);
    } catch (e) {
      value = PaymentsState.error(e.toString());
    }
  }

  Future<PurchaseEntity> processMockPayment(
    String productId,
    String? tripId,
  ) async {
    value = PaymentsState.loading();
    try {
      final purchase = await _paymentsRepository.createMockPurchase(
        productId: productId,
        tripId: tripId,
      );
      final confirmed = await _paymentsRepository.confirmMockPayment(
        purchase.id,
      );
      await loadProductsAndPurchases();
      return confirmed;
    } catch (e) {
      value = PaymentsState.error(e.toString());
      rethrow;
    }
  }
}
