import 'package:flutter/material.dart';
import '../../icons/twogo_icons.dart';
import '../../tokens/colors.dart';
import '../../tokens/typography.dart';
import '../buttons/twogo_icon_button.dart';

/// Minimalist App Bar component for 2GO Mobile Design System.
class TwoGoAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color backgroundColor;

  const TwoGoAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
    this.backgroundColor = TwoGoColors.surfacePrimary,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    Widget? leadingButton = leading;

    if (leadingButton == null && showBackButton) {
      final canPop = ModalRoute.of(context)?.canPop ?? false;
      if (canPop || onBackPressed != null) {
        leadingButton = TwoGoIconButton(
          icon: TwoGoIcons.back,
          onPressed: () {
            if (onBackPressed != null) {
              onBackPressed!();
            } else {
              Navigator.of(context).maybePop();
            }
          },
        );
      }
    }

    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: leadingButton,
      title:
          titleWidget ??
          (title != null
              ? Text(
                  title!,
                  style: TwoGoTypography.titleLarge.copyWith(
                    color: TwoGoColors.contentPrimary,
                  ),
                )
              : null),
      actions: actions,
    );
  }
}
