import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

class PlanningStepPlaceholderView extends StatelessWidget {
  final int currentStep;
  final String stepName;

  const PlanningStepPlaceholderView({
    super.key,
    required this.currentStep,
    required this.stepName,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(TwoGoSpacing.md),
      child: TwoGoCard(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              TwoGoIcons.travel,
              size: TwoGoSizing.iconXl,
              color: TwoGoColors.brandLime,
            ),
            const SizedBox(height: TwoGoSpacing.md),
            Text(
              'Etapa $currentStep: $stepName',
              textAlign: TextAlign.center,
              style: TwoGoTypography.titleMedium.copyWith(
                color: TwoGoColors.textPrimary,
              ),
            ),
            const SizedBox(height: TwoGoSpacing.xs),
            Text(
              'Fundação do Wizard pronta para receber os campos reais',
              textAlign: TextAlign.center,
              style: TwoGoTypography.bodySmall.copyWith(
                color: TwoGoColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
