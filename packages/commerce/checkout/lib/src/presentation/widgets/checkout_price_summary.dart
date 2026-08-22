import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';
import 'package:twogo_payments/twogo_payments.dart';

class CheckoutPriceSummary extends StatelessWidget {
  final CheckoutSummary summary;

  const CheckoutPriceSummary({
    super.key,
    required this.summary,
  });

  String _formatCurrency(double value, String currency) {
    final formatted = value.toStringAsFixed(2).replaceAll('.', ',');
    return 'R\$ $formatted';
  }

  @override
  Widget build(BuildContext context) {
    final pricing = summary.pricing;
    final hasDiscount = pricing.discountAmount > 0;

    return TwoGoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(TwoGoSpacing.xs),
                decoration: BoxDecoration(
                  color: TwoGoColors.contentPrimary.withValues(alpha: 0.05),
                  borderRadius:
                      BorderRadius.circular(TwoGoRadius.small),
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  color: TwoGoColors.contentPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: TwoGoSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      summary.productName,
                      style: TwoGoTypography.headlineSmall.copyWith(
                        color: TwoGoColors.contentPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (summary.productDescription != null)
                      Text(
                        summary.productDescription!,
                        style: TwoGoTypography.bodySmall.copyWith(
                          color: TwoGoColors.neutral600,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: TwoGoSpacing.md),
          const TwoGoDivider(),
          const SizedBox(height: TwoGoSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Preço original:',
                style: TwoGoTypography.bodyMedium.copyWith(
                  color: TwoGoColors.neutral600,
                ),
              ),
              Text(
                _formatCurrency(pricing.originalAmount, pricing.currency),
                style: TwoGoTypography.bodyMedium.copyWith(
                  color: TwoGoColors.neutral800,
                  decoration: hasDiscount ? TextDecoration.lineThrough : null,
                ),
              ),
            ],
          ),
          if (hasDiscount) ...[
            const SizedBox(height: TwoGoSpacing.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Desconto aplicado:',
                  style: TwoGoTypography.bodyMedium.copyWith(
                    color: TwoGoColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '-${_formatCurrency(pricing.discountAmount, pricing.currency)}',
                  style: TwoGoTypography.bodyMedium.copyWith(
                    color: TwoGoColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: TwoGoSpacing.sm),
          const TwoGoDivider(),
          const SizedBox(height: TwoGoSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total:',
                style: TwoGoTypography.headlineSmall.copyWith(
                  color: TwoGoColors.contentPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _formatCurrency(pricing.finalAmount, pricing.currency),
                style: TwoGoTypography.headlineMedium.copyWith(
                  color: TwoGoColors.contentPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
