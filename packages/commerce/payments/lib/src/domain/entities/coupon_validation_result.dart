import 'applied_coupon.dart';
import 'checkout_pricing.dart';

/// Soft coupon validate from `POST /trips/:tripId/coupons/validate`.
class CouponValidationResult {
  final bool valid;
  final String? code;
  final String? reason;
  final CheckoutPricing? pricing;
  final AppliedCoupon? coupon;

  const CouponValidationResult({
    required this.valid,
    this.code,
    this.reason,
    this.pricing,
    this.coupon,
  });
}
