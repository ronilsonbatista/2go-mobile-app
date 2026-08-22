import 'package:app_roteiros_api/app_roteiros_api.dart';
import 'billing_api_client.dart';
import '../models/product_dto.dart';
import '../models/purchase_dto.dart';
import 'payments_remote_datasource.dart';

class PaymentsRemoteDataSourceImpl implements PaymentsRemoteDataSource {
  final BillingApiClient _billingApiClient;

  PaymentsRemoteDataSourceImpl({
    required BillingApiClient billingApiClient,
  }) : _billingApiClient = billingApiClient;

  @override
  Future<List<ProductDto>> getActiveProducts() async {
    return [];
  }

  @override
  Future<List<PurchaseDto>> getMyPurchases() async {
    return [];
  }

  @override
  Future<CheckoutSummaryResponseDto> getCheckoutSummary(String tripId) async {
    return await _billingApiClient.getCheckoutSummary(tripId);
  }

  @override
  Future<CheckoutQuoteResponseDto> getCheckoutQuote(
    String tripId, {
    String? couponCode,
  }) async {
    return await _billingApiClient.getCheckoutQuote(
      tripId,
      CheckoutQuoteDto(couponCode: couponCode),
    );
  }

  @override
  Future<CheckoutResponseDto> processCheckout({
    required String tripId,
    required String paymentMethod,
    String? couponCode,
    String? cardToken,
    int? installments,
    String? idempotencyKey,
  }) async {
    final methodEnum = paymentMethod.toUpperCase() == 'CARD' ||
            paymentMethod.toUpperCase() == 'CREDIT_CARD'
        ? PaymentMethodType.CARD
        : PaymentMethodType.PIX;

    final dto = CheckoutPurchaseDto(
      tripId: tripId,
      paymentMethod: methodEnum,
      couponCode: couponCode,
      cardToken: cardToken,
      installments: installments ?? 1,
    );

    return await _billingApiClient.processCheckout(
      dto,
      idempotencyKey: idempotencyKey,
    );
  }

  @override
  Future<Map<String, dynamic>> getPurchaseStatus(String purchaseId) async {
    return await _billingApiClient.getPurchaseStatus(purchaseId);
  }

  @override
  Future<PurchaseDto> createMockPurchase(String productId, String? tripId) async {
    throw UnimplementedError('Mock payments are disabled in production API');
  }

  @override
  Future<PurchaseDto> confirmMockPayment(String purchaseId) async {
    throw UnimplementedError('Mock payments are disabled in production API');
  }
}
