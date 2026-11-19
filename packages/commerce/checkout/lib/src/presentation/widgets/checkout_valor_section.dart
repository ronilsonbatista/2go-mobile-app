import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';
import 'package:twogo_payments/twogo_payments.dart';

import '../../domain/checkout_currency_format.dart';

/// Valor / cupom / você pagará block under the trip card.
class CheckoutValorSection extends StatelessWidget {
  final CheckoutPricing pricing;
  final AppliedCoupon? coupon;
  final VoidCallback onAddCoupon;
  final VoidCallback? onRemoveCoupon;

  const CheckoutValorSection({
    super.key,
    required this.pricing,
    this.coupon,
    required this.onAddCoupon,
    this.onRemoveCoupon,
  });

  bool get _hasDiscount =>
      coupon != null && coupon!.applied && pricing.discountAmount > 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Valor',
              style: TwoGoTypography.bodyLarge.copyWith(
                color: TwoGoColors.contentPrimary,
              ),
            ),
            Text(
              formatCheckoutCurrency(pricing.originalAmount),
              style: TwoGoTypography.bodyLarge.copyWith(
                color: TwoGoColors.contentPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        if (_hasDiscount) ...[
          const SizedBox(height: TwoGoSpacing.xs),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Cupom aplicado',
                  style: TwoGoTypography.bodyMedium.copyWith(
                    color: TwoGoColors.contentSecondary,
                  ),
                ),
              ),
              Text(
                '−${formatCheckoutCurrency(pricing.discountAmount)}',
                style: TwoGoTypography.bodyMedium.copyWith(
                  color: TwoGoColors.feedbackError,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: TwoGoSpacing.xxs),
              InkWell(
                onTap: onRemoveCoupon,
                borderRadius: TwoGoRadius.borderFull,
                child: const Padding(
                  padding: EdgeInsets.all(TwoGoSpacing.xxs),
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: TwoGoColors.contentSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: TwoGoSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'você pagará',
                style: TwoGoTypography.bodyLarge.copyWith(
                  color: TwoGoColors.contentPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                formatCheckoutCurrency(pricing.finalAmount),
                style: TwoGoTypography.titleMedium.copyWith(
                  color: TwoGoColors.contentPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ] else ...[
          const SizedBox(height: TwoGoSpacing.xs),
          InkWell(
            onTap: onAddCoupon,
            borderRadius: TwoGoRadius.borderMedium,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: TwoGoSpacing.xxs),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.local_activity_outlined,
                    size: 18,
                    color: TwoGoColors.feedbackError.withValues(alpha: 0.85),
                  ),
                  const SizedBox(width: TwoGoSpacing.xxs),
                  Text(
                    'Adicionar cupom',
                    style: TwoGoTypography.labelLarge.copyWith(
                      color: TwoGoColors.feedbackError.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
