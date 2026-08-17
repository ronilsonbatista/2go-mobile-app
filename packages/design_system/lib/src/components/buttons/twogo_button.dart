import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radius.dart';
import '../../tokens/sizing.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';
import '../indicators/twogo_loading_indicator.dart';

enum TwoGoButtonVariant { primary, secondary, tertiary, destructive }

/// Primary button component for 2GO Mobile Design System.
class TwoGoButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final TwoGoButtonVariant variant;
  final bool loading;
  final bool fullWidth;
  final Widget? leadingIcon;
  final Widget? trailingIcon;

  const TwoGoButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = TwoGoButtonVariant.primary,
    this.loading = false,
    this.fullWidth = true,
    this.leadingIcon,
    this.trailingIcon,
  });

  /// Alias property for backwards compatibility with earlier scaffold
  String get label => text;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || loading;

    Color backgroundColor;
    Color foregroundColor;
    BorderSide borderSide = BorderSide.none;

    switch (variant) {
      case TwoGoButtonVariant.primary:
        backgroundColor = isDisabled
            ? TwoGoColors.actionPrimaryDisabled
            : TwoGoColors.actionPrimary;
        foregroundColor = isDisabled
            ? TwoGoColors.contentDisabled
            : TwoGoColors.neutral900;
        break;

      case TwoGoButtonVariant.secondary:
        backgroundColor = isDisabled
            ? TwoGoColors.surfaceDisabled
            : TwoGoColors.actionSecondary;
        foregroundColor = isDisabled
            ? TwoGoColors.contentDisabled
            : TwoGoColors.contentPrimary;
        borderSide = const BorderSide(color: TwoGoColors.borderDefault);
        break;

      case TwoGoButtonVariant.tertiary:
        backgroundColor = Colors.transparent;
        foregroundColor = isDisabled
            ? TwoGoColors.contentDisabled
            : TwoGoColors.contentPrimary;
        break;

      case TwoGoButtonVariant.destructive:
        backgroundColor = isDisabled
            ? TwoGoColors.surfaceDisabled
            : TwoGoColors.error;
        foregroundColor = isDisabled
            ? TwoGoColors.contentDisabled
            : TwoGoColors.neutral0;
        break;
    }

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading) ...[
          TwoGoLoadingIndicator(size: 20, color: foregroundColor),
          const SizedBox(width: TwoGoSpacing.xs),
        ] else ...[
          if (leadingIcon != null) ...[
            IconTheme(
              data: IconThemeData(color: foregroundColor, size: 20),
              child: leadingIcon!,
            ),
            const SizedBox(width: TwoGoSpacing.xs),
          ],
          Flexible(
            child: Text(
              text,
              style: TwoGoTypography.labelLarge.copyWith(
                color: foregroundColor,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (trailingIcon != null) ...[
            const SizedBox(width: TwoGoSpacing.xs),
            IconTheme(
              data: IconThemeData(color: foregroundColor, size: 20),
              child: trailingIcon!,
            ),
          ],
        ],
      ],
    );

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: 0,
      minimumSize: Size(
        fullWidth ? double.infinity : 0,
        TwoGoSizing.buttonHeight,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: TwoGoSpacing.lg,
        vertical: TwoGoSpacing.sm,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: TwoGoRadius.borderLarge,
      ),
      side: borderSide,
    );

    Widget result = ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: buttonStyle,
      child: content,
    );

    if (!fullWidth) {
      return result;
    }

    return SizedBox(width: double.infinity, child: result);
  }
}
