import '../entities/checkout_summary.dart';
import '../entities/product_entity.dart';
import '../entities/purchase_entity.dart';

abstract class PaymentsRepository {
  Future<List<ProductEntity>> getActiveProducts();
  Future<List<PurchaseEntity>> getMyPurchases();
  Future<CheckoutSummary> getCheckoutSummary(String tripId);
  Future<CheckoutSummary> getCheckoutQuote(String tripId, {String? couponCode});
  Future<PurchaseEntity> createMockPurchase({
    required String productId,
    String? tripId,
  });
  Future<PurchaseEntity> confirmMockPayment(String purchaseId);
}
