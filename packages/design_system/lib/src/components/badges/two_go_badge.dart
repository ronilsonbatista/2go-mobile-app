import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radius.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';

/// Variant style for [TwoGoBadge].
enum TwoGoBadgeVariant { brand, error, info, neutral }

/// A generic indicator badge component supporting dot, count, or label variants.
class TwoGoBadge extends StatelessWidget {
  const TwoGoBadge({
    super.key,
    this.count,
    this.label,
    this.variant = TwoGoBadgeVariant.error,
    this.semanticLabel,
    this.isDot = false,
  });

  final int? count;
  final String? label;
  final TwoGoBadgeVariant variant;
  final String? semanticLabel;
  final bool isDot;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (variant) {
      case TwoGoBadgeVariant.brand:
        backgroundColor = TwoGoColors.brandLime;
        textColor = TwoGoColors.contentPrimary;
      case TwoGoBadgeVariant.error:
        backgroundColor = TwoGoColors.feedbackError;
        textColor = TwoGoColors.surfacePrimary;
      case TwoGoBadgeVariant.info:
        backgroundColor = TwoGoColors.feedbackInfo;
        textColor = TwoGoColors.surfacePrimary;
      case TwoGoBadgeVariant.neutral:
        backgroundColor = TwoGoColors.surfaceSecondary;
        textColor = TwoGoColors.contentSecondary;
    }

    if (isDot) {
      return Semantics(
        label: semanticLabel ?? 'Novo item',
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
        ),
      );
    }

    final textContent =
        label ?? (count != null ? (count! > 99 ? '99+' : '$count') : '');
    final accessibilityLabel =
        semanticLabel ??
        (count != null ? '$count notificações' : (label ?? 'Badge'));

    return Semantics(
      label: accessibilityLabel,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: TwoGoSpacing.xs,
          vertical: 2,
        ),
        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(TwoGoRadius.full),
        ),
        child: Center(
          child: Text(
            textContent,
            style: TwoGoTypography.labelSmall.copyWith(
              color: textColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              height: 1.1,
            ),
          ),
        ),
      ),
    );
  }
}
