import 'package:flutter/material.dart';
import '../../icons/twogo_icons.dart';
import '../../tokens/colors.dart';
import '../../tokens/radius.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';
import '../buttons/twogo_icon_button.dart';

/// Reusable Bottom Sheet component for 2GO Mobile Design System.
///
/// Features keyboard-aware layout (`viewInsets`), drag handle, title, and a
/// max-height cap so the header stays below the status bar / Dynamic Island.
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
    final media = MediaQuery.of(context);
    final bottomInset = keyboardAware ? media.viewInsets.bottom : 0.0;
    // Cap height so the sheet title never rides into the status bar /
    // Dynamic Island when the keyboard opens — only the body shrinks.
    final maxHeight = media.size.height - media.padding.top - bottomInset;

    return AnimatedPadding(
      padding: EdgeInsets.only(bottom: bottomInset),
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
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
                              onPressed: () =>
                                  Navigator.of(context).maybePop(),
                            ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                  ],
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(TwoGoSpacing.md),
                      child: child,
                    ),
                  ),
                  if (primaryAction != null || secondaryAction != null) ...[
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(TwoGoSpacing.md),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (primaryAction != null) primaryAction!,
                          if (primaryAction != null &&
                              secondaryAction != null)
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
        ),
      ),
    );
  }
}
