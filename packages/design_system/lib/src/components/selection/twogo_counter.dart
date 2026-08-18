import 'package:flutter/material.dart';
import '../buttons/twogo_icon_button.dart';
import '../../icons/twogo_icons.dart';
import '../../tokens/colors.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';

class TwoGoCounter extends StatelessWidget {
  final int value;
  final int min;
  final int? max;
  final ValueChanged<int>? onChanged;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final String? label;
  final String? subtitle;

  const TwoGoCounter({
    super.key,
    required this.value,
    this.min = 0,
    this.max,
    this.onChanged,
    this.onIncrement,
    this.onDecrement,
    this.label,
    this.subtitle,
  });

  bool get canDecrement => value > min;
  bool get canIncrement => max == null || value < max!;

  void _handleDecrement() {
    if (!canDecrement) return;
    if (onDecrement != null) {
      onDecrement!();
    } else if (onChanged != null) {
      onChanged!(value - 1);
    }
  }

  void _handleIncrement() {
    if (!canIncrement) return;
    if (onIncrement != null) {
      onIncrement!();
    } else if (onChanged != null) {
      onChanged!(value + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasLabel = label != null && label!.isNotEmpty;

    return Semantics(
      label: label,
      value: '$value',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (hasLabel)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label!,
                    style: TwoGoTypography.titleSmall.copyWith(
                      color: TwoGoColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: TwoGoSpacing.xxs),
                    Text(
                      subtitle!,
                      style: TwoGoTypography.bodySmall.copyWith(
                        color: TwoGoColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TwoGoIconButton(
                icon: TwoGoIcons.remove,
                onPressed: canDecrement ? _handleDecrement : null,
                variant: TwoGoIconButtonVariant.secondary,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: TwoGoSpacing.md,
                ),
                child: SizedBox(
                  width: TwoGoSpacing.xl,
                  child: Text(
                    '$value',
                    textAlign: TextAlign.center,
                    style: TwoGoTypography.titleMedium.copyWith(
                      color: TwoGoColors.textPrimary,
                    ),
                  ),
                ),
              ),
              TwoGoIconButton(
                icon: TwoGoIcons.add,
                onPressed: canIncrement ? _handleIncrement : null,
                variant: TwoGoIconButtonVariant.secondary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
