import '../entities/product_entity.dart';
import '../entities/purchase_entity.dart';

abstract class PaymentsRepository {
  Future<List<ProductEntity>> getActiveProducts();
  Future<List<PurchaseEntity>> getMyPurchases();
  Future<PurchaseEntity> createMockPurchase({
    required String productId,
    String? tripId,
  });
  Future<PurchaseEntity> confirmMockPayment(String purchaseId);
}
