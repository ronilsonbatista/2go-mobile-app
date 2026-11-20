import 'checkout_coupon_dto.dart';
import 'checkout_pricing_dto.dart';
import 'checkout_product_dto.dart';
import 'payment_method_availability_dto.dart';

class CheckoutQuoteResponseDto {
  final String tripId;
  final bool alreadyUnlocked;
  final CheckoutProductDto product;
  final CheckoutPricingDto pricing;
  final CheckoutCouponDto? coupon;
  final List<String> supportedPaymentMethods;
  final List<PaymentMethodAvailabilityDto> paymentMethodAvailability;
  final String? existingPurchaseId;
  final String? existingPurchaseStatus;

  const CheckoutQuoteResponseDto({
    required this.tripId,
    required this.alreadyUnlocked,
    required this.product,
    required this.pricing,
    this.coupon,
    required this.supportedPaymentMethods,
    this.paymentMethodAvailability = const [],
    this.existingPurchaseId,
    this.existingPurchaseStatus,
  });

  factory CheckoutQuoteResponseDto.fromJson(Map<String, dynamic> json) {
    return CheckoutQuoteResponseDto(
      tripId: json['tripId'] as String? ?? '',
      alreadyUnlocked: json['alreadyUnlocked'] as bool? ?? false,
      product: CheckoutProductDto.fromJson(
        json['product'] as Map<String, dynamic>? ?? {},
      ),
      pricing: CheckoutPricingDto.fromJson(
        json['pricing'] as Map<String, dynamic>? ?? {},
      ),
      coupon: json['coupon'] != null
          ? CheckoutCouponDto.fromJson(json['coupon'] as Map<String, dynamic>)
          : null,
      supportedPaymentMethods:
          (json['supportedPaymentMethods'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          ['PIX', 'CARD'],
      paymentMethodAvailability:
          (json['paymentMethodAvailability'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(PaymentMethodAvailabilityDto.fromJson)
              .toList() ??
          const [],
      existingPurchaseId: json['existingPurchaseId'] as String?,
      existingPurchaseStatus: json['existingPurchaseStatus'] as String?,
    );
  }
}
