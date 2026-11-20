import 'applied_coupon.dart';
import 'checkout_pricing.dart';
import 'payment_method_availability.dart';

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
  final List<PaymentMethodAvailability> paymentMethodAvailability;
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
    this.paymentMethodAvailability = const [],
    this.existingPurchaseId,
    this.existingPurchaseStatus,
  });

  CheckoutSummary copyWith({
    CheckoutPricing? pricing,
    AppliedCoupon? coupon,
    bool clearCoupon = false,
    List<String>? supportedPaymentMethods,
    List<PaymentMethodAvailability>? paymentMethodAvailability,
  }) {
    return CheckoutSummary(
      tripId: tripId,
      alreadyUnlocked: alreadyUnlocked,
      productId: productId,
      productType: productType,
      productName: productName,
      productDescription: productDescription,
      pricing: pricing ?? this.pricing,
      coupon: clearCoupon ? null : (coupon ?? this.coupon),
      supportedPaymentMethods:
          supportedPaymentMethods ?? this.supportedPaymentMethods,
      paymentMethodAvailability:
          paymentMethodAvailability ?? this.paymentMethodAvailability,
      existingPurchaseId: existingPurchaseId,
      existingPurchaseStatus: existingPurchaseStatus,
    );
  }
}
