import 'package:dio/dio.dart';
import 'package:app_roteiros_api/app_roteiros_api.dart';

import '../../domain/entities/card_intent_result.dart';
import '../../domain/entities/checkout_pricing.dart';
import '../../domain/entities/applied_coupon.dart';
import '../../domain/entities/coupon_validation_result.dart';
import '../../domain/entities/expire_purchase_result.dart';

class BillingApiClient {
  final Dio _dio;

  BillingApiClient(this._dio);

  Future<CheckoutSummaryResponseDto> getCheckoutSummary(String tripId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/trips/$tripId/checkout-summary',
    );
    return CheckoutSummaryResponseDto.fromJson(response.data ?? {});
  }

  Future<CheckoutQuoteResponseDto> getCheckoutQuote(
    String tripId,
    CheckoutQuoteDto dto,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/trips/$tripId/checkout-quote',
      data: dto.toJson(),
    );
    return CheckoutQuoteResponseDto.fromJson(response.data ?? {});
  }

  /// Soft validate — HTTP 200 even when `valid: false` (Core PR #4).
  Future<CouponValidationResult> validateCoupon(
    String tripId, {
    required String couponCode,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/trips/$tripId/coupons/validate',
      data: {'couponCode': couponCode},
    );
    final json = response.data ?? {};
    final pricingJson = json['pricing'] as Map<String, dynamic>?;
    final couponJson = json['coupon'] as Map<String, dynamic>?;
    return CouponValidationResult(
      valid: json['valid'] as bool? ?? false,
      code: json['code'] as String?,
      reason: json['reason'] as String?,
      pricing: pricingJson == null
          ? null
          : CheckoutPricing(
              originalAmount: (pricingJson['originalAmount'] as num?)?.toDouble() ?? 0,
              discountAmount: (pricingJson['discountAmount'] as num?)?.toDouble() ?? 0,
              finalAmount: (pricingJson['finalAmount'] as num?)?.toDouble() ?? 0,
              currency: pricingJson['currency'] as String? ?? 'BRL',
            ),
      coupon: couponJson == null
          ? null
          : AppliedCoupon(
              code: couponJson['code'] as String? ?? '',
              applied: couponJson['applied'] as bool? ?? true,
              discountType: couponJson['discountType'] as String?,
              discountValue: (couponJson['discountValue'] as num?)?.toDouble(),
              description: couponJson['description'] as String?,
            ),
    );
  }

  Future<CheckoutResponseDto> processCheckout(
    CheckoutPurchaseDto dto, {
    String? idempotencyKey,
  }) async {
    final options = idempotencyKey != null && idempotencyKey.isNotEmpty
        ? Options(headers: {'idempotency-key': idempotencyKey})
        : null;

    final response = await _dio.post<Map<String, dynamic>>(
      '/purchases/checkout',
      data: dto.toJson(),
      options: options,
    );
    return CheckoutResponseDto.fromJson(response.data ?? {});
  }

  Future<CardIntentResult> createCardIntent({
    required String tripId,
    String? couponCode,
    int? installments,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/purchases/card-intent',
      data: {
        'tripId': tripId,
        if (couponCode != null && couponCode.isNotEmpty) 'couponCode': couponCode,
        if (installments != null) 'installments': installments,
      },
    );
    final json = response.data ?? {};
    final pricingJson = json['pricing'] as Map<String, dynamic>?;
    return CardIntentResult(
      intentId: json['intentId'] as String? ?? '',
      tripId: json['tripId'] as String? ?? tripId,
      status: json['status'] as String? ?? 'READY',
      publicKey: json['publicKey'] as String?,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'BRL',
      clientSecret: json['clientSecret'] as String?,
      expiresAt: json['expiresAt'] as String?,
      message: json['message'] as String?,
      pricing: pricingJson == null
          ? null
          : CheckoutPricing(
              originalAmount: (pricingJson['originalAmount'] as num?)?.toDouble() ?? 0,
              discountAmount: (pricingJson['discountAmount'] as num?)?.toDouble() ?? 0,
              finalAmount: (pricingJson['finalAmount'] as num?)?.toDouble() ?? 0,
              currency: pricingJson['currency'] as String? ?? 'BRL',
            ),
    );
  }

  Future<ExpirePurchaseResult> expirePurchase(String purchaseId) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/purchases/$purchaseId/expire',
    );
    final json = response.data ?? {};
    final expiredAt = json['expiredAt'];
    return ExpirePurchaseResult(
      purchaseId: json['purchaseId'] as String? ?? purchaseId,
      status: json['status'] as String? ?? 'EXPIRED',
      expiredAt: expiredAt is String ? expiredAt : expiredAt?.toString(),
      message: json['message'] as String?,
    );
  }

  Future<Map<String, dynamic>> getPurchaseStatus(String purchaseId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/purchases/$purchaseId/status',
    );
    return response.data ?? {};
  }
}
