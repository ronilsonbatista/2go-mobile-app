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
    // Will be backed by products client when needed
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
  Future<PurchaseDto> createMockPurchase(String productId, String? tripId) async {
    throw UnimplementedError('Mock payments are disabled in production API');
  }

  @override
  Future<PurchaseDto> confirmMockPayment(String purchaseId) async {
    throw UnimplementedError('Mock payments are disabled in production API');
  }
}
