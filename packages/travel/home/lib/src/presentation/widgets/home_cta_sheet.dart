import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

/// White overlapping sheet with course CTAs (Home-9/10/11).
class HomeCtaSheet extends StatelessWidget {
  const HomeCtaSheet({
    required this.onCreateItinerary,
    required this.onAccessItineraries,
    this.topRadius = 36,
    super.key,
  });

  final VoidCallback onCreateItinerary;
  final VoidCallback onAccessItineraries;
  final double topRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: TwoGoColors.backgroundPrimary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(topRadius),
          topRight: Radius.circular(topRadius),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          TwoGoSpacing.lg,
          TwoGoSpacing.xl,
          TwoGoSpacing.lg,
          TwoGoSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: onCreateItinerary,
                style: FilledButton.styleFrom(
                  backgroundColor: TwoGoColors.neutral900,
                  foregroundColor: TwoGoColors.neutral0,
                  shape: const StadiumBorder(),
                  textStyle: TwoGoTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Criar novo roteiro'),
              ),
            ),
            const SizedBox(height: TwoGoSpacing.md),
            Center(
              child: TextButton(
                onPressed: onAccessItineraries,
                style: TextButton.styleFrom(
                  foregroundColor: TwoGoColors.contentPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: TwoGoSpacing.md,
                    vertical: TwoGoSpacing.xs,
                  ),
                ),
                child: Text(
                  'Acessar roteiros',
                  style: TwoGoTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: TwoGoColors.contentPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
