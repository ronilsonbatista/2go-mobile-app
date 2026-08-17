import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radius.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';
import '../../accessibility/twogo_touch_target.dart';

/// Variant style for [TwoGoPill].
enum TwoGoPillVariant {
  /// Light background with neutral border and text.
  neutral,

  /// White background with subtle border.
  outlined,

  /// Highlighted active pill.
  active,
}

/// A compact pill badge or interactive pill button component for status, timer, or filter items.
class TwoGoPill extends StatelessWidget {
  const TwoGoPill({
    required this.label,
    super.key,
    this.variant = TwoGoPillVariant.neutral,
    this.leading,
    this.onTap,
    this.semanticLabel,
  });

  final String label;
  final TwoGoPillVariant variant;
  final Widget? leading;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color borderColor;
    Color textColor;

    switch (variant) {
      case TwoGoPillVariant.neutral:
        backgroundColor = TwoGoColors.surfaceSecondary;
        borderColor = TwoGoColors.borderDefault;
        textColor = TwoGoColors.contentSecondary;
      case TwoGoPillVariant.outlined:
        backgroundColor = TwoGoColors.surfacePrimary;
        borderColor = TwoGoColors.borderDefault;
        textColor = TwoGoColors.contentPrimary;
      case TwoGoPillVariant.active:
        backgroundColor = TwoGoColors.brandLime;
        borderColor = TwoGoColors.brandLime;
        textColor = TwoGoColors.contentPrimary;
    }

    final child = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(
        horizontal: TwoGoSpacing.md,
        vertical: TwoGoSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(TwoGoRadius.full),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: TwoGoSpacing.xs),
          ],
          Text(
            label,
            style: TwoGoTypography.labelMedium.copyWith(
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return Semantics(
        label: semanticLabel ?? label,
        container: true,
        child: child,
      );
    }

    return TwoGoTouchTarget(
      minWidth: 48,
      minHeight: 36,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(TwoGoRadius.full),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(TwoGoRadius.full),
          child: Semantics(
            button: true,
            label: semanticLabel ?? label,
            child: child,
          ),
        ),
      ),
    );
  }
}
