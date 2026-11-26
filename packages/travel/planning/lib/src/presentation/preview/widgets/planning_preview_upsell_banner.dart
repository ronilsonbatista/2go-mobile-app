import 'package:flutter/material.dart';
import 'package:twogo_core/twogo_core.dart';
import 'package:twogo_design_system/design_system.dart';

import '../../../domain/models/planning_preview.dart';

/// Dark upsell strip under the countdown — opens the unlock modal.
class PlanningPreviewUpsellBanner extends StatelessWidget {
  const PlanningPreviewUpsellBanner({
    super.key,
    required this.offer,
    required this.onTap,
  });

  final PlanningUnlockOffer offer;
  final VoidCallback onTap;

  static const Color _gold = Color(0xFFE0A93A);

  String get _price {
    if (offer.currency == 'BRL') {
      return TripDurationPricing.formatBrl(offer.price);
    }
    return '${offer.currency} ${offer.price.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  Widget build(BuildContext context) {
    if (!offer.available) return const SizedBox.shrink();

    // Design banner is a soft pill (~20 radius), not DS large=16.
    const radius = 20.0;
    return Material(
      color: TwoGoColors.neutral900,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: TwoGoSpacing.md,
            vertical: TwoGoSpacing.sm + 2,
          ),
          child: Row(
            children: [
              const _UpsellBadge(size: 42),
              const SizedBox(width: TwoGoSpacing.sm),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: TwoGoTypography.bodyMedium.copyWith(
                      color: TwoGoColors.contentInverse,
                      height: 1.3,
                      fontSize: 14,
                    ),
                    children: [
                      const TextSpan(
                        text: 'Tenha acesso a todos os dias de roteiro por apenas ',
                      ),
                      TextSpan(
                        text: _price,
                        style: const TextStyle(
                          color: _gold,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Gold ribbon badge used on banner + unlock modal.
class PlanningUpsellBadge extends StatelessWidget {
  const PlanningUpsellBadge({super.key, this.size = 72});

  final double size;

  @override
  Widget build(BuildContext context) => _UpsellBadge(size: size);
}

class _UpsellBadge extends StatelessWidget {
  const _UpsellBadge({required this.size});

  final double size;

  static const Color _gold = Color(0xFFE0A93A);
  static const Color _ribbon = Color(0xFFD32F2F);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.15,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            bottom: 0,
            left: size * 0.18,
            child: Transform.rotate(
              angle: -0.35,
              child: Container(
                width: size * 0.22,
                height: size * 0.45,
                decoration: BoxDecoration(
                  color: _ribbon,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: size * 0.18,
            child: Transform.rotate(
              angle: 0.35,
              child: Container(
                width: size * 0.22,
                height: size * 0.45,
                decoration: BoxDecoration(
                  color: _ribbon,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _gold,
              border: Border.all(color: _ribbon, width: size * 0.06),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              Icons.flight_rounded,
              color: _ribbon,
              size: size * 0.42,
            ),
          ),
        ],
      ),
    );
  }
}
