import 'package:app_roteiros_api/app_roteiros_api.dart';
import '../../domain/entities/applied_coupon.dart';
import '../../domain/entities/checkout_pricing.dart';
import '../../domain/entities/checkout_summary.dart';
import '../../domain/entities/payment_method_availability.dart';

List<PaymentMethodAvailability> _mapAvailability(
  List<PaymentMethodAvailabilityDto> items,
) {
  return items
      .map(
        (m) => PaymentMethodAvailability(
          method: m.method,
          available: m.available,
          status: m.status,
          reason: m.reason,
        ),
      )
      .toList(growable: false);
}

extension CheckoutSummaryResponseDtoMapper on CheckoutSummaryResponseDto {
  CheckoutSummary toEntity() {
    return CheckoutSummary(
      tripId: tripId,
      alreadyUnlocked: alreadyUnlocked,
      productId: product.id,
      productType: product.type,
      productName: product.name,
      productDescription: product.description,
      pricing: CheckoutPricing(
        originalAmount: pricing.originalAmount,
        discountAmount: pricing.discountAmount,
        finalAmount: pricing.finalAmount,
        currency: pricing.currency,
        amount: pricing.amount,
        days: pricing.days,
        tier: pricing.tier,
      ),
      coupon: coupon != null
          ? AppliedCoupon(
              code: coupon!.code,
              applied: coupon!.applied,
              discountType: coupon!.discountType,
              discountValue: coupon!.discountValue,
              description: coupon!.description,
            )
          : null,
      supportedPaymentMethods: supportedPaymentMethods,
      paymentMethodAvailability: _mapAvailability(paymentMethodAvailability),
      existingPurchaseId: existingPurchaseId,
      existingPurchaseStatus: existingPurchaseStatus,
    );
  }
}

extension CheckoutQuoteResponseDtoMapper on CheckoutQuoteResponseDto {
  CheckoutSummary toEntity() {
    return CheckoutSummary(
      tripId: tripId,
      alreadyUnlocked: alreadyUnlocked,
      productId: product.id,
      productType: product.type,
      productName: product.name,
      productDescription: product.description,
      pricing: CheckoutPricing(
        originalAmount: pricing.originalAmount,
        discountAmount: pricing.discountAmount,
        finalAmount: pricing.finalAmount,
        currency: pricing.currency,
        amount: pricing.amount,
        days: pricing.days,
        tier: pricing.tier,
      ),
      coupon: coupon != null
          ? AppliedCoupon(
              code: coupon!.code,
              applied: coupon!.applied,
              discountType: coupon!.discountType,
              discountValue: coupon!.discountValue,
              description: coupon!.description,
            )
          : null,
      supportedPaymentMethods: supportedPaymentMethods,
      paymentMethodAvailability: _mapAvailability(paymentMethodAvailability),
      existingPurchaseId: existingPurchaseId,
      existingPurchaseStatus: existingPurchaseStatus,
    );
  }
}
