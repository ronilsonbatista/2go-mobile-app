import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';
import 'package:twogo_payments/twogo_payments.dart';

class CheckoutCouponSection extends StatefulWidget {
  final AppliedCoupon? coupon;
  final bool isQuoting;
  final String? quoteError;
  final ValueChanged<String> onApplyCoupon;
  final VoidCallback onRemoveCoupon;

  const CheckoutCouponSection({
    super.key,
    this.coupon,
    required this.isQuoting,
    this.quoteError,
    required this.onApplyCoupon,
    required this.onRemoveCoupon,
  });

  @override
  State<CheckoutCouponSection> createState() => _CheckoutCouponSectionState();
}

class _CheckoutCouponSectionState extends State<CheckoutCouponSection> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleApply() {
    final code = _controller.text.trim();
    if (code.isNotEmpty) {
      widget.onApplyCoupon(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasCoupon = widget.coupon != null && widget.coupon!.applied;

    return TwoGoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_offer_outlined,
                color: TwoGoColors.contentPrimary,
                size: 20,
              ),
              const SizedBox(width: TwoGoSpacing.xs),
              Text(
                'Cupom de Desconto',
                style: TwoGoTypography.headlineSmall.copyWith(
                  color: TwoGoColors.contentPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: TwoGoSpacing.sm),
          if (hasCoupon) ...[
            Container(
              padding: const EdgeInsets.all(TwoGoSpacing.sm),
              decoration: BoxDecoration(
                color: TwoGoColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(TwoGoRadius.medium),
                border: Border.all(
                  color: TwoGoColors.success.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: TwoGoColors.success,
                    size: 20,
                  ),
                  const SizedBox(width: TwoGoSpacing.xs),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cupom ${widget.coupon!.code} Aplicado!',
                          style: TwoGoTypography.bodyMedium.copyWith(
                            color: TwoGoColors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (widget.coupon!.description != null)
                          Text(
                            widget.coupon!.description!,
                            style: TwoGoTypography.bodySmall.copyWith(
                              color: TwoGoColors.neutral700,
                            ),
                          ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: widget.isQuoting ? null : widget.onRemoveCoupon,
                    child: Text(
                      'Remover',
                      style: TwoGoTypography.labelSmall.copyWith(
                        color: TwoGoColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: TwoGoTextField(
                    controller: _controller,
                    hint: 'Digite seu cupom (ex: PROMO10)',
                    enabled: !widget.isQuoting,
                  ),
                ),
                const SizedBox(width: TwoGoSpacing.xs),
                TwoGoButton(
                  text: 'Aplicar',
                  fullWidth: false,
                  loading: widget.isQuoting,
                  onPressed: widget.isQuoting ? null : _handleApply,
                ),
              ],
            ),
            if (widget.quoteError != null) ...[
              const SizedBox(height: TwoGoSpacing.xs),
              TwoGoInlineFeedback(
                message: widget.quoteError!,
                variant: TwoGoInlineFeedbackVariant.error,
              ),
            ],
          ],
        ],
      ),
    );
  }
}
