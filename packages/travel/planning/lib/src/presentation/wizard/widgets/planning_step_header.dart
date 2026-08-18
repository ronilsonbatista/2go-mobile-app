import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

class PlanningStepHeader extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final String title;
  final String? subtitle;
  final VoidCallback onBack;

  const PlanningStepHeader({
    super.key,
    required this.currentStep,
    this.totalSteps = 6,
    required this.title,
    this.subtitle,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (currentStep / totalSteps).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            TwoGoIconButton(
              icon: TwoGoIcons.back,
              onPressed: onBack,
              variant: TwoGoIconButtonVariant.ghost,
            ),
            const SizedBox(width: TwoGoSpacing.xs),
            Icon(
              TwoGoIcons.flight,
              size: TwoGoSizing.iconSm,
              color: TwoGoColors.contentSecondary,
            ),
            const SizedBox(width: TwoGoSpacing.xs),
            Expanded(child: TwoGoProgressBar(progress: progress)),
            const SizedBox(width: TwoGoSpacing.sm),
            Text(
              '$currentStep de $totalSteps',
              style: TwoGoTypography.labelMedium.copyWith(
                color: TwoGoColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: TwoGoSpacing.md),
        Text(
          title,
          style: TwoGoTypography.headlineMedium.copyWith(
            color: TwoGoColors.textPrimary,
          ),
        ),
        if (subtitle != null && subtitle!.isNotEmpty) ...[
          const SizedBox(height: TwoGoSpacing.xs),
          Text(
            subtitle!,
            style: TwoGoTypography.bodyMedium.copyWith(
              color: TwoGoColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
