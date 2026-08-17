import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radius.dart';
import '../../tokens/spacing.dart';

/// Primitive Surface Card component for 2GO Mobile Design System.
class TwoGoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool selected;
  final bool disabled;
  final BorderSide? border;
  final Color? backgroundColor;
  final BorderRadiusGeometry borderRadius;

  const TwoGoCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(TwoGoSpacing.md),
    this.onTap,
    this.selected = false,
    this.disabled = false,
    this.border,
    this.backgroundColor,
    this.borderRadius = TwoGoRadius.borderLarge,
  });

  @override
  Widget build(BuildContext context) {
    Color bg =
        backgroundColor ??
        (disabled
            ? TwoGoColors.surfaceDisabled
            : (selected
                  ? TwoGoColors.brandLimeLight.withValues(alpha: 0.2)
                  : TwoGoColors.surfacePrimary));

    BorderSide borderSide =
        border ??
        BorderSide(
          color: selected
              ? TwoGoColors.borderFocused
              : (disabled
                    ? TwoGoColors.surfaceDisabled
                    : TwoGoColors.borderDefault),
          width: selected ? 2.0 : 1.0,
        );

    Widget content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: borderRadius,
        border: Border.fromBorderSide(borderSide),
      ),
      child: child,
    );

    if (onTap != null && !disabled) {
      return InkWell(
        onTap: onTap,
        borderRadius: borderRadius as BorderRadius?,
        child: content,
      );
    }

    return content;
  }
}
