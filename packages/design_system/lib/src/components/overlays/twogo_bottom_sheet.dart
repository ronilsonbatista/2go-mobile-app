import 'package:flutter/material.dart';
import '../../icons/twogo_icons.dart';
import '../../tokens/colors.dart';
import '../../tokens/radius.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';
import '../buttons/twogo_icon_button.dart';

/// Reusable Bottom Sheet component for 2GO Mobile Design System.
///
/// Features keyboard-aware layout (`viewInsets`), drag handle, title, and safe area.
class TwoGoBottomSheet extends StatelessWidget {
  final String? title;
  final Widget child;
  final Widget? primaryAction;
  final Widget? secondaryAction;
  final bool showCloseButton;
  final bool keyboardAware;

  const TwoGoBottomSheet({
    super.key,
    this.title,
    required this.child,
    this.primaryAction,
    this.secondaryAction,
    this.showCloseButton = true,
    this.keyboardAware = true,
  });

  /// Helper to show a modal bottom sheet with [TwoGoBottomSheet].
  static Future<T?> show<T>(
    BuildContext context, {
    String? title,
    required Widget child,
    Widget? primaryAction,
    Widget? secondaryAction,
    bool showCloseButton = true,
    bool keyboardAware = true,
    bool isDismissible = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TwoGoBottomSheet(
        title: title,
        primaryAction: primaryAction,
        secondaryAction: secondaryAction,
        showCloseButton: showCloseButton,
        keyboardAware: keyboardAware,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = keyboardAware
        ? MediaQuery.viewInsetsOf(context).bottom
        : 0.0;

    return AnimatedPadding(
      padding: EdgeInsets.only(bottom: bottomInset),
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      child: SafeArea(
        top: false,
        child: Container(
          decoration: const BoxDecoration(
            color: TwoGoColors.surfacePrimary,
            borderRadius: TwoGoRadius.sheetTop,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: TwoGoSpacing.xs),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: TwoGoColors.neutral300,
                    borderRadius: TwoGoRadius.borderFull,
                  ),
                ),
              ),

              // Header
              if (title != null || showCloseButton) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    TwoGoSpacing.md,
                    TwoGoSpacing.xs,
                    TwoGoSpacing.xs,
                    TwoGoSpacing.xs,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: title != null
                            ? Text(
                                title!,
                                style: TwoGoTypography.titleLarge.copyWith(
                                  color: TwoGoColors.contentPrimary,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                      if (showCloseButton)
                        TwoGoIconButton(
                          icon: TwoGoIcons.close,
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                    ],
                  ),
                ),
                const Divider(height: 1),
              ],

              // Content body
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(TwoGoSpacing.md),
                  child: child,
                ),
              ),

              // Footer Actions
              if (primaryAction != null || secondaryAction != null) ...[
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(TwoGoSpacing.md),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (primaryAction != null) primaryAction!,
                      if (primaryAction != null && secondaryAction != null)
                        const SizedBox(height: TwoGoSpacing.xs),
                      if (secondaryAction != null) secondaryAction!,
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
