import 'package:flutter/material.dart';
import '../../accessibility/twogo_touch_target.dart';
import '../../icons/twogo_icons.dart';
import '../../tokens/colors.dart';
import '../../tokens/radius.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';

/// Generic List Tile component for 2GO Mobile Design System.
class TwoGoListTile extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enabled;
  final EdgeInsetsGeometry padding;

  TwoGoListTile({
    super.key,
    Widget? leading,
    IconData? leadingIcon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.enabled = true,
    this.padding = const EdgeInsets.symmetric(
      horizontal: TwoGoSpacing.md,
      vertical: TwoGoSpacing.sm,
    ),
  }) : leading =
           leading ??
           (leadingIcon != null
               ? Icon(leadingIcon, color: TwoGoColors.contentSecondary)
               : null);

  @override
  Widget build(BuildContext context) {
    final isEnabled = enabled && onTap != null;

    final defaultTrailing = Icon(
      TwoGoIcons.chevronRight,
      color: isEnabled
          ? TwoGoColors.contentSecondary
          : TwoGoColors.contentDisabled,
      size: 20,
    );

    return TwoGoTouchTarget(
      minHeight: 56,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: TwoGoRadius.borderMedium,
        child: Padding(
          padding: padding,
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: TwoGoSpacing.md),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TwoGoTypography.titleMedium.copyWith(
                        color: isEnabled
                            ? TwoGoColors.contentPrimary
                            : TwoGoColors.contentDisabled,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: TwoGoSpacing.xxs),
                      Text(
                        subtitle!,
                        style: TwoGoTypography.bodySmall.copyWith(
                          color: TwoGoColors.contentSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: TwoGoSpacing.sm),
              trailing ?? defaultTrailing,
            ],
          ),
        ),
      ),
    );
  }
}
