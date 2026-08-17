import 'package:flutter/material.dart';
import '../../accessibility/twogo_touch_target.dart';
import '../../tokens/colors.dart';
import '../../tokens/radius.dart';

enum TwoGoIconButtonVariant { primary, secondary, ghost }

/// Icon Button component for 2GO Mobile Design System.
class TwoGoIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final TwoGoIconButtonVariant variant;
  final String? tooltip;
  final double size;
  final Color? iconColor;
  final Color? backgroundColor;

  const TwoGoIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.variant = TwoGoIconButtonVariant.ghost,
    this.tooltip,
    this.size = 24.0,
    this.iconColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;

    Color bg;
    Color fg;

    switch (variant) {
      case TwoGoIconButtonVariant.primary:
        bg =
            backgroundColor ??
            (enabled
                ? TwoGoColors.brandLime
                : TwoGoColors.actionPrimaryDisabled);
        fg =
            iconColor ??
            (enabled ? TwoGoColors.neutral900 : TwoGoColors.contentDisabled);
        break;
      case TwoGoIconButtonVariant.secondary:
        bg =
            backgroundColor ??
            (enabled
                ? TwoGoColors.surfaceSecondary
                : TwoGoColors.surfaceDisabled);
        fg =
            iconColor ??
            (enabled
                ? TwoGoColors.contentPrimary
                : TwoGoColors.contentDisabled);
        break;
      case TwoGoIconButtonVariant.ghost:
        bg = backgroundColor ?? Colors.transparent;
        fg =
            iconColor ??
            (enabled
                ? TwoGoColors.contentPrimary
                : TwoGoColors.contentDisabled);
        break;
    }

    Widget button = InkWell(
      onTap: onPressed,
      borderRadius: TwoGoRadius.borderFull,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Icon(icon, size: size, color: fg),
      ),
    );

    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }

    return TwoGoTouchTarget(child: button);
  }
}
