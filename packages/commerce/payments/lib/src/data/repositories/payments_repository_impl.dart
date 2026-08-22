import '../../domain/entities/checkout_payment_result.dart';
import '../../domain/entities/checkout_summary.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/purchase_entity.dart';
import '../../domain/entities/purchase_status_result.dart';
import '../../domain/repositories/payments_repository.dart';
import '../datasources/payments_remote_datasource.dart';
import '../models/checkout_summary_mapper.dart';

class PaymentsRepositoryImpl implements PaymentsRepository {
  final PaymentsRemoteDataSource _remoteDataSource;

  PaymentsRepositoryImpl({required PaymentsRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<List<ProductEntity>> getActiveProducts() async {
    final dtos = await _remoteDataSource.getActiveProducts();
    return dtos.map((d) => d.toEntity()).toList();
  }

  @override
  Future<List<PurchaseEntity>> getMyPurchases() async {
    final dtos = await _remoteDataSource.getMyPurchases();
    return dtos.map((d) => d.toEntity()).toList();
  }

  @override
  Future<CheckoutSummary> getCheckoutSummary(String tripId) async {
    final dto = await _remoteDataSource.getCheckoutSummary(tripId);
    return dto.toEntity();
  }

  @override
  Future<CheckoutSummary> getCheckoutQuote(
    String tripId, {
    String? couponCode,
  }) async {
    final dto = await _remoteDataSource.getCheckoutQuote(
      tripId,
      couponCode: couponCode,
    );
    return dto.toEntity();
  }

  @override
  Future<CheckoutPaymentResult> processCheckoutPayment({
    required String tripId,
    required String paymentMethod,
    String? couponCode,
    String? cardToken,
    int? installments,
    String? idempotencyKey,
  }) async {
    final responseDto = await _remoteDataSource.processCheckout(
      tripId: tripId,
      paymentMethod: paymentMethod,
      couponCode: couponCode,
      cardToken: cardToken,
      installments: installments,
      idempotencyKey: idempotencyKey,
    );

    return CheckoutPaymentResult(
      purchaseId: responseDto.purchaseId,
      status: responseDto.status.name,
      paymentMethod: responseDto.paymentMethod.name,
      pixDetails: responseDto.pixDetails != null
          ? PixDetails(
              copyPaste: responseDto.pixDetails!.copyPaste,
              qrCodeBase64: responseDto.pixDetails!.qrCodeBase64,
              expiresAt: responseDto.pixDetails!.expiresAt?.toIso8601String(),
            )
          : null,
    );
  }

  @override
  Future<PurchaseStatusResult> getPurchaseStatus(String purchaseId) async {
    final map = await _remoteDataSource.getPurchaseStatus(purchaseId);
    final pixData = map['pixDetails'] as Map<String, dynamic>?;
    return PurchaseStatusResult(
      purchaseId: map['purchaseId'] as String? ?? purchaseId,
      status: map['status'] as String? ?? 'PENDING',
      paidAt: map['paidAt'] as String?,
      premiumUnlocked: map['premiumUnlocked'] as bool? ?? false,
      pixDetails: pixData != null
          ? PixDetails(
              copyPaste: pixData['copyPaste'] as String?,
              qrCodeBase64: pixData['qrCodeBase64'] as String?,
              expiresAt: pixData['expiresAt'] as String?,
            )
          : null,
    );
  }

  @override
  Future<PurchaseEntity> createMockPurchase({
    required String productId,
    String? tripId,
  }) async {
    final dto = await _remoteDataSource.createMockPurchase(productId, tripId);
    return dto.toEntity();
  }

  @override
  Future<PurchaseEntity> confirmMockPayment(String purchaseId) async {
    final dto = await _remoteDataSource.confirmMockPayment(purchaseId);
    return dto.toEntity();
  }
}
