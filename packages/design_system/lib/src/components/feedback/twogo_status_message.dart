import 'package:flutter/material.dart';
import '../../icons/twogo_icons.dart';
import '../../tokens/colors.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';

enum TwoGoStatusMessageType { success, error, warning, info }

/// Generic Status Message layout primitive for 2GO Mobile Design System.
///
/// Can be composed by feature screens (e.g. Payment success/failure) without
/// tying the component itself to domain business rules.
class TwoGoStatusMessage extends StatelessWidget {
  final TwoGoStatusMessageType type;
  final Widget? icon;
  final String title;
  final String? description;
  final Widget? action;

  const TwoGoStatusMessage({
    super.key,
    this.type = TwoGoStatusMessageType.info,
    this.icon,
    required this.title,
    this.description,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    Color iconBgColor;
    IconData defaultIcon;

    switch (type) {
      case TwoGoStatusMessageType.success:
        iconBgColor = TwoGoColors.successLight;
        defaultIcon = TwoGoIcons.checkCircle;
        break;
      case TwoGoStatusMessageType.error:
        iconBgColor = TwoGoColors.errorLight;
        defaultIcon = TwoGoIcons.error;
        break;
      case TwoGoStatusMessageType.warning:
        iconBgColor = TwoGoColors.warningLight;
        defaultIcon = TwoGoIcons.warning;
        break;
      case TwoGoStatusMessageType.info:
        iconBgColor = TwoGoColors.infoLight;
        defaultIcon = TwoGoIcons.info;
        break;
    }

    final defaultIconWidget = Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Icon(
        defaultIcon,
        size: 44,
        color: type == TwoGoStatusMessageType.success
            ? TwoGoColors.feedbackSuccess
            : (type == TwoGoStatusMessageType.error
                  ? TwoGoColors.feedbackError
                  : TwoGoColors.contentPrimary),
      ),
    );

    return Padding(
      padding: const EdgeInsets.all(TwoGoSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          icon ?? defaultIconWidget,
          const SizedBox(height: TwoGoSpacing.lg),
          Text(
            title,
            style: TwoGoTypography.headlineMedium.copyWith(
              color: TwoGoColors.contentPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          if (description != null) ...[
            const SizedBox(height: TwoGoSpacing.sm),
            Text(
              description!,
              style: TwoGoTypography.bodyMedium.copyWith(
                color: TwoGoColors.contentSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (action != null) ...[
            const SizedBox(height: TwoGoSpacing.xl),
            action!,
          ],
        ],
      ),
    );
  }
}
