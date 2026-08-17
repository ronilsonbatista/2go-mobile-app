import 'package:flutter/material.dart';
import '../../icons/twogo_icons.dart';
import '../../tokens/colors.dart';
import '../../tokens/radius.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';

enum TwoGoSnackbarVariant { success, error, warning, info }

/// Floating Toast / Snackbar for 2GO Mobile Design System.
///
/// Matches dark feedback bar visual style shown in product references.
class TwoGoSnackbar extends StatelessWidget {
  final String message;
  final TwoGoSnackbarVariant variant;
  final Widget? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const TwoGoSnackbar({
    super.key,
    required this.message,
    this.variant = TwoGoSnackbarVariant.info,
    this.icon,
    this.actionLabel,
    this.onAction,
  });

  /// Displays the snackbar using [ScaffoldMessenger].
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> show(
    BuildContext context, {
    required String message,
    TwoGoSnackbarVariant variant = TwoGoSnackbarVariant.info,
    Widget? icon,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    return messenger.showSnackBar(
      SnackBar(
        elevation: 4,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        padding: EdgeInsets.zero,
        duration: duration,
        content: TwoGoSnackbar(
          message: message,
          variant: variant,
          icon: icon,
          actionLabel: actionLabel,
          onAction: onAction,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color indicatorColor;
    IconData defaultIconData;

    switch (variant) {
      case TwoGoSnackbarVariant.success:
        indicatorColor = TwoGoColors.feedbackSuccess;
        defaultIconData = TwoGoIcons.checkCircle;
        break;
      case TwoGoSnackbarVariant.error:
        indicatorColor = TwoGoColors.feedbackError;
        defaultIconData = TwoGoIcons.error;
        break;
      case TwoGoSnackbarVariant.warning:
        indicatorColor = TwoGoColors.feedbackWarning;
        defaultIconData = TwoGoIcons.warning;
        break;
      case TwoGoSnackbarVariant.info:
        indicatorColor = TwoGoColors.feedbackInfo;
        defaultIconData = TwoGoIcons.info;
        break;
    }

    final leadingWidget =
        icon ??
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: indicatorColor,
            shape: BoxShape.circle,
          ),
          child: Icon(defaultIconData, size: 16, color: TwoGoColors.neutral0),
        );

    return Container(
      margin: const EdgeInsets.all(TwoGoSpacing.xs),
      padding: const EdgeInsets.symmetric(
        horizontal: TwoGoSpacing.md,
        vertical: TwoGoSpacing.sm,
      ),
      decoration: const BoxDecoration(
        color: TwoGoColors.toastBackground,
        borderRadius: TwoGoRadius.borderMedium,
      ),
      child: Row(
        children: [
          leadingWidget,
          const SizedBox(width: TwoGoSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: TwoGoTypography.bodyMedium.copyWith(
                color: TwoGoColors.contentInverse,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(width: TwoGoSpacing.sm),
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel!,
                style: TwoGoTypography.labelMedium.copyWith(
                  color: TwoGoColors.brandLime,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
