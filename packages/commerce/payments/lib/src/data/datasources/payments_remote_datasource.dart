import '../models/product_dto.dart';
import '../models/purchase_dto.dart';

abstract class PaymentsRemoteDataSource {
  Future<List<ProductDto>> getActiveProducts();
  Future<List<PurchaseDto>> getMyPurchases();
  Future<PurchaseDto> createMockPurchase(String productId, String? tripId);
  Future<PurchaseDto> confirmMockPayment(String purchaseId);
}
