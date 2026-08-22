import 'package:app_roteiros_api/app_roteiros_api.dart';
import '../models/product_dto.dart';
import '../models/purchase_dto.dart';

abstract class PaymentsRemoteDataSource {
  Future<List<ProductDto>> getActiveProducts();
  Future<List<PurchaseDto>> getMyPurchases();
  Future<CheckoutSummaryResponseDto> getCheckoutSummary(String tripId);
  Future<CheckoutQuoteResponseDto> getCheckoutQuote(
    String tripId, {
    String? couponCode,
  });
  Future<PurchaseDto> createMockPurchase(String productId, String? tripId);
  Future<PurchaseDto> confirmMockPayment(String purchaseId);
}
