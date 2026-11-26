import 'package:flutter/material.dart';
import 'package:twogo_core/twogo_core.dart';
import 'package:twogo_design_system/design_system.dart';

import '../../../domain/models/planning_preview.dart';
import 'planning_preview_upsell_banner.dart';

/// Centered unlock / upsell modal. CTA **Aproveitar** → login handoff.
class PlanningUnlockSheet extends StatelessWidget {
  final PlanningUnlockOffer offer;
  final VoidCallback onUnlockRequested;
  final VoidCallback onDismiss;

  const PlanningUnlockSheet({
    super.key,
    required this.offer,
    required this.onUnlockRequested,
    required this.onDismiss,
  });

  String _formatPrice() {
    if (offer.currency == 'BRL') {
      return TripDurationPricing.formatBrl(offer.price);
    }
    return '${offer.currency} ${offer.price.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Material(
        color: TwoGoColors.neutral0,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Soft map-ish header wash
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 120,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      TwoGoColors.neutral100,
                      TwoGoColors.neutral0,
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Material(
                      color: TwoGoColors.neutral100,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: onDismiss,
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            Icons.close_rounded,
                            size: 20,
                            color: TwoGoColors.neutral800,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const PlanningUpsellBadge(size: 88),
                  const SizedBox(height: TwoGoSpacing.md),
                  Text(
                    'Tenha acesso a todos os dias de roteiro por apenas',
                    textAlign: TextAlign.center,
                    style: TwoGoTypography.bodyLarge.copyWith(
                      color: TwoGoColors.neutral700,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: TwoGoSpacing.sm),
                  Text(
                    _formatPrice(),
                    textAlign: TextAlign.center,
                    style: TwoGoTypography.headlineMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      color: TwoGoColors.neutral900,
                    ),
                  ),
                  const SizedBox(height: TwoGoSpacing.lg),
                  const _BenefitRow(text: 'Dicas exclusivas'),
                  const SizedBox(height: TwoGoSpacing.sm),
                  const _BenefitRow(text: 'Roteiro personalizado'),
                  const SizedBox(height: TwoGoSpacing.sm),
                  const _BenefitRow(text: 'Acesso offline ao seu roteiro'),
                  const SizedBox(height: TwoGoSpacing.xl),
                  TwoGoButton(
                    text: 'Aproveitar',
                    onPressed: offer.available ? onUnlockRequested : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            color: TwoGoColors.success,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            size: 14,
            color: TwoGoColors.neutral0,
          ),
        ),
        const SizedBox(width: TwoGoSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: TwoGoTypography.bodyMedium.copyWith(
              color: TwoGoColors.neutral700,
            ),
          ),
        ),
      ],
    );
  }
}
