import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';
import '../../../domain/models/planning_preview.dart';

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
    final currencySymbol = offer.currency == 'BRL' ? 'R\$' : offer.currency;
    return '$currencySymbol ${offer.price.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(TwoGoSpacing.lg),
      decoration: const BoxDecoration(
        color: TwoGoColors.neutral0,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(TwoGoSpacing.lg),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Close header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const TwoGoBadge(
                  label: 'ACESSO COMPLETO',
                  variant: TwoGoBadgeVariant.brand,
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: onDismiss,
                  color: TwoGoColors.neutral600,
                ),
              ],
            ),
            const SizedBox(height: TwoGoSpacing.md),

            // Title & Price
            Text(
              offer.name,
              style: TwoGoTypography.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: TwoGoColors.neutral900,
              ),
            ),
            const SizedBox(height: TwoGoSpacing.xs),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  _formatPrice(),
                  style: TwoGoTypography.headlineMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    color: TwoGoColors.brandLimePressed,
                  ),
                ),
                const SizedBox(width: TwoGoSpacing.xs),
                Text(
                  '/ pagamento único',
                  style: TwoGoTypography.bodySmall.copyWith(
                    color: TwoGoColors.neutral600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: TwoGoSpacing.lg),

            // Benefits
            _buildBenefitRow(
              Icons.calendar_month_rounded,
              'Acesso ilimitado a todos os dias do roteiro',
            ),
            const SizedBox(height: TwoGoSpacing.sm),
            _buildBenefitRow(
              Icons.restaurant_menu_rounded,
              'Seleção exclusiva de restaurantes e experiências',
            ),
            const SizedBox(height: TwoGoSpacing.sm),
            _buildBenefitRow(
              Icons.edit_road_rounded,
              'Personalização total do itinerário',
            ),
            const SizedBox(height: TwoGoSpacing.xl),

            // CTA Button
            TwoGoButton(
              text: 'Desbloquear Roteiro',
              onPressed: offer.available ? onUnlockRequested : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: TwoGoColors.neutral800),
        const SizedBox(width: TwoGoSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: TwoGoTypography.bodyMedium.copyWith(
              color: TwoGoColors.neutral900,
            ),
          ),
        ),
      ],
    );
  }
}
