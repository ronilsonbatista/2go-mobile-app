import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';
import '../../icons/twogo_icons.dart';

/// Variant style for [TwoGoInlineFeedback].
enum TwoGoInlineFeedbackVariant { error, success, warning, info }

/// An inline form validation or status feedback message.
class TwoGoInlineFeedback extends StatelessWidget {
  const TwoGoInlineFeedback({
    required this.message,
    super.key,
    this.variant = TwoGoInlineFeedbackVariant.error,
    this.showIcon = true,
  });

  final String message;
  final TwoGoInlineFeedbackVariant variant;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    Color textColor;
    IconData iconData;

    switch (variant) {
      case TwoGoInlineFeedbackVariant.error:
        textColor = TwoGoColors.feedbackError;
        iconData = TwoGoIcons.error;
      case TwoGoInlineFeedbackVariant.success:
        textColor = TwoGoColors.feedbackSuccess;
        iconData = TwoGoIcons.check;
      case TwoGoInlineFeedbackVariant.warning:
        textColor = TwoGoColors.feedbackWarning;
        iconData = TwoGoIcons.warning;
      case TwoGoInlineFeedbackVariant.info:
        textColor = TwoGoColors.feedbackInfo;
        iconData = TwoGoIcons.info;
    }

    return Semantics(
      liveRegion: true,
      label: message,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showIcon) ...[
            Icon(iconData, size: 14, color: textColor),
            const SizedBox(width: TwoGoSpacing.xs),
          ],
          Flexible(
            child: Text(
              message,
              style: TwoGoTypography.labelMedium.copyWith(
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
