import 'package:flutter/material.dart';
import '../../accessibility/twogo_touch_target.dart';
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
              // Course Age steppers: white circle + black − / + (refs e66a8526, b88c4ee4).
              _StepperCircleButton(
                icon: TwoGoIcons.remove,
                enabled: canDecrement,
                onPressed: canDecrement ? _handleDecrement : null,
                semanticLabel: 'Diminuir',
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
              _StepperCircleButton(
                icon: TwoGoIcons.add,
                enabled: canIncrement,
                onPressed: canIncrement ? _handleIncrement : null,
                semanticLabel: 'Aumentar',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// White circle + black +/− control used by Age (and other) count steppers.
class _StepperCircleButton extends StatelessWidget {
  const _StepperCircleButton({
    required this.icon,
    required this.enabled,
    required this.onPressed,
    required this.semanticLabel,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback? onPressed;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final fg = enabled ? TwoGoColors.neutral900 : TwoGoColors.contentDisabled;

    return TwoGoTouchTarget(
      child: Semantics(
        button: true,
        enabled: enabled,
        label: semanticLabel,
        child: Material(
          color: TwoGoColors.neutral0,
          shape: const CircleBorder(),
          elevation: enabled ? 1 : 0,
          shadowColor: Colors.black26,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: SizedBox(
              width: 40,
              height: 40,
              child: Icon(icon, size: 22, color: fg),
            ),
          ),
        ),
      ),
    );
  }
}
