import 'package:flutter/material.dart';
import '../../accessibility/twogo_touch_target.dart';
import '../../tokens/colors.dart';
import '../../tokens/radius.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';

/// Checkbox component for 2GO Mobile Design System.
class TwoGoCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final String? label;
  final bool disabled;
  final String? errorText;

  const TwoGoCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.disabled = false,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = !disabled && onChanged != null;
    final hasError = errorText != null && errorText!.isNotEmpty;

    Color boxBg = Colors.transparent;
    Color borderColor = TwoGoColors.borderDefault;

    if (!isEnabled) {
      boxBg = value
          ? TwoGoColors.actionPrimaryDisabled
          : TwoGoColors.surfaceDisabled;
      borderColor = TwoGoColors.surfaceDisabled;
    } else if (hasError) {
      borderColor = TwoGoColors.borderError;
      boxBg = value ? TwoGoColors.borderError : Colors.transparent;
    } else if (value) {
      boxBg = TwoGoColors.brandLime;
      borderColor = TwoGoColors.brandLime;
    }

    Widget box = Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: boxBg,
        borderRadius: TwoGoRadius.borderSmall,
        border: Border.all(color: borderColor, width: 1.5),
      ),
      alignment: Alignment.center,
      child: value
          ? Icon(
              Icons.check_rounded,
              size: 16,
              color: isEnabled
                  ? TwoGoColors.neutral900
                  : TwoGoColors.contentDisabled,
            )
          : null,
    );

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        box,
        if (label != null) ...[
          const SizedBox(width: TwoGoSpacing.xs),
          Flexible(
            child: Text(
              label!,
              style: TwoGoTypography.bodyMedium.copyWith(
                color: isEnabled
                    ? TwoGoColors.contentPrimary
                    : TwoGoColors.contentDisabled,
              ),
            ),
          ),
        ],
      ],
    );

    return TwoGoTouchTarget(
      child: InkWell(
        onTap: isEnabled ? () => onChanged!(!value) : null,
        borderRadius: TwoGoRadius.borderSmall,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: TwoGoSpacing.xxs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              content,
              if (hasError) ...[
                const SizedBox(height: TwoGoSpacing.xxs),
                Text(
                  errorText!,
                  style: TwoGoTypography.labelSmall.copyWith(
                    color: TwoGoColors.feedbackError,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
