import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

class FoundationsCatalogView extends StatelessWidget {
  const FoundationsCatalogView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(TwoGoSpacing.md),
      children: [
        const Text('Colors', style: TwoGoTypography.headlineMedium),
        const SizedBox(height: TwoGoSpacing.sm),
        Wrap(
          spacing: TwoGoSpacing.xs,
          runSpacing: TwoGoSpacing.xs,
          children: [
            _colorChip('Brand Lime', TwoGoColors.brandLime),
            _colorChip('Neutral 0', TwoGoColors.neutral0, border: true),
            _colorChip('Neutral 100', TwoGoColors.neutral100),
            _colorChip('Neutral 500', TwoGoColors.neutral500),
            _colorChip('Neutral 900', TwoGoColors.neutral900),
            _colorChip('Success', TwoGoColors.success),
            _colorChip('Error', TwoGoColors.error),
            _colorChip('Warning', TwoGoColors.warning),
            _colorChip('Info', TwoGoColors.info),
          ],
        ),

        const TwoGoDivider(space: TwoGoSpacing.xl),

        const Text('Typography', style: TwoGoTypography.headlineMedium),
        const SizedBox(height: TwoGoSpacing.sm),
        const Text('Display (32px Bold)', style: TwoGoTypography.display),
        const Text(
          'Headline Large (24px Bold)',
          style: TwoGoTypography.headlineLarge,
        ),
        const Text(
          'Headline Medium (20px Bold)',
          style: TwoGoTypography.headlineMedium,
        ),
        const Text(
          'Headline Small (18px Semi-bold)',
          style: TwoGoTypography.headlineSmall,
        ),
        const Text(
          'Title Large (16px Semi-bold)',
          style: TwoGoTypography.titleLarge,
        ),
        const Text(
          'Body Large (16px Regular)',
          style: TwoGoTypography.bodyLarge,
        ),
        const Text(
          'Body Medium (14px Regular)',
          style: TwoGoTypography.bodyMedium,
        ),
        const Text(
          'Label Small (10px Medium)',
          style: TwoGoTypography.labelSmall,
        ),

        const TwoGoDivider(space: TwoGoSpacing.xl),

        const Text('Spacing Scale', style: TwoGoTypography.headlineMedium),
        const SizedBox(height: TwoGoSpacing.sm),
        _spacingRow('xxs (4px)', TwoGoSpacing.xxs),
        _spacingRow('xs (8px)', TwoGoSpacing.xs),
        _spacingRow('sm (12px)', TwoGoSpacing.sm),
        _spacingRow('md (16px)', TwoGoSpacing.md),
        _spacingRow('lg (24px)', TwoGoSpacing.lg),
        _spacingRow('xl (32px)', TwoGoSpacing.xl),
        _spacingRow('xxl (48px)', TwoGoSpacing.xxl),

        const TwoGoDivider(space: TwoGoSpacing.xl),

        const Text('Radius Scale', style: TwoGoTypography.headlineMedium),
        const SizedBox(height: TwoGoSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _radiusBox('Small (4)', TwoGoRadius.borderSmall),
            _radiusBox('Medium (8)', TwoGoRadius.borderMedium),
            _radiusBox('Large (16)', TwoGoRadius.borderLarge),
            _radiusBox('Full (999)', TwoGoRadius.borderFull),
          ],
        ),
      ],
    );
  }

  Widget _colorChip(String label, Color color, {bool border = false}) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(TwoGoSpacing.xs),
      decoration: BoxDecoration(
        color: color,
        borderRadius: TwoGoRadius.borderMedium,
        border: border ? Border.all(color: TwoGoColors.borderDefault) : null,
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TwoGoTypography.labelSmall.copyWith(
              color: color.computeLuminance() > 0.5
                  ? TwoGoColors.neutral900
                  : TwoGoColors.neutral0,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _spacingRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TwoGoSpacing.xxs),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: TwoGoTypography.bodySmall),
          ),
          Container(height: 16, width: value * 4, color: TwoGoColors.brandLime),
        ],
      ),
    );
  }

  Widget _radiusBox(String label, BorderRadius radius) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: TwoGoColors.surfaceSecondary,
        borderRadius: radius,
        border: Border.all(color: TwoGoColors.borderFocused),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TwoGoTypography.labelSmall,
        textAlign: TextAlign.center,
      ),
    );
  }
}
