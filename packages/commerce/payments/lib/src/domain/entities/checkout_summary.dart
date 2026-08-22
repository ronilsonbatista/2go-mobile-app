import 'applied_coupon.dart';
import 'checkout_pricing.dart';

class CheckoutSummary {
  final String tripId;
  final bool alreadyUnlocked;
  final String productId;
  final String productType;
  final String productName;
  final String? productDescription;
  final CheckoutPricing pricing;
  final AppliedCoupon? coupon;
  final List<String> supportedPaymentMethods;
  final String? existingPurchaseId;
  final String? existingPurchaseStatus;

  const CheckoutSummary({
    required this.tripId,
    required this.alreadyUnlocked,
    required this.productId,
    required this.productType,
    required this.productName,
    this.productDescription,
    required this.pricing,
    this.coupon,
    required this.supportedPaymentMethods,
    this.existingPurchaseId,
    this.existingPurchaseStatus,
  });
}
