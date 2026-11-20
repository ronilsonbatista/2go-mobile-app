import 'package:app_roteiros_api/app_roteiros_api.dart';
import '../../domain/entities/card_intent_result.dart';
import '../../domain/entities/coupon_validation_result.dart';
import '../../domain/entities/expire_purchase_result.dart';
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
  Future<CouponValidationResult> validateCoupon(
    String tripId, {
    required String couponCode,
  });
  Future<CheckoutResponseDto> processCheckout({
    required String tripId,
    required String paymentMethod,
    String? couponCode,
    String? cardToken,
    int? installments,
    String? idempotencyKey,
  });
  Future<CardIntentResult> createCardIntent({
    required String tripId,
    String? couponCode,
    int? installments,
  });
  Future<ExpirePurchaseResult> expirePurchase(String purchaseId);
  Future<Map<String, dynamic>> getPurchaseStatus(String purchaseId);
  Future<PurchaseDto> createMockPurchase(String productId, String? tripId);
  Future<PurchaseDto> confirmMockPayment(String purchaseId);
}
