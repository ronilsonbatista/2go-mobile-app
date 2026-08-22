import '../entities/checkout_payment_result.dart';
import '../entities/checkout_summary.dart';
import '../entities/product_entity.dart';
import '../entities/purchase_entity.dart';
import '../entities/purchase_status_result.dart';

abstract class PaymentsRepository {
  Future<List<ProductEntity>> getActiveProducts();
  Future<List<PurchaseEntity>> getMyPurchases();
  Future<CheckoutSummary> getCheckoutSummary(String tripId);
  Future<CheckoutSummary> getCheckoutQuote(String tripId, {String? couponCode});
  Future<CheckoutPaymentResult> processCheckoutPayment({
    required String tripId,
    required String paymentMethod,
    String? couponCode,
    String? cardToken,
    int? installments,
    String? idempotencyKey,
  });
  Future<PurchaseStatusResult> getPurchaseStatus(String purchaseId);
  Future<PurchaseEntity> createMockPurchase({
    required String productId,
    String? tripId,
  });
  Future<PurchaseEntity> confirmMockPayment(String purchaseId);
}
