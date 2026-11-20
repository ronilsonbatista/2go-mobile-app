import 'package:flutter/material.dart';
import '../../icons/twogo_icons.dart';
import '../../tokens/colors.dart';
import '../../tokens/radius.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';

enum TwoGoSnackbarVariant { success, error, warning, info, connectivity }

/// Floating Toast / Snackbar for 2GO Mobile Design System.
///
/// Dark bar + colored leading icon + bottom progress line that drains over
/// [duration] (matches login OTP invalid / resend toasts).
///
/// [TwoGoSnackbarVariant.connectivity] uses the coral “Sem conexão…” pattern.
class TwoGoSnackbar extends StatelessWidget {
  final String message;
  final TwoGoSnackbarVariant variant;
  final Widget? icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Duration? progressDuration;

  const TwoGoSnackbar({
    super.key,
    required this.message,
    this.variant = TwoGoSnackbarVariant.info,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.progressDuration,
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
    bool showProgress = true,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    return messenger.showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        padding: EdgeInsets.zero,
        margin: const EdgeInsets.fromLTRB(
          TwoGoSpacing.md,
          0,
          TwoGoSpacing.md,
          TwoGoSpacing.md,
        ),
        duration: duration,
        content: TwoGoSnackbar(
          message: message,
          variant: variant,
          icon: icon,
          actionLabel: actionLabel,
          onAction: onAction,
          progressDuration: showProgress ? duration : null,
        ),
      ),
    );
  }

  /// Coral connectivity toast matching design copy.
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>
  showNoConnection(
    BuildContext context, {
    String message = 'Sem conexão com a internet!',
    Duration duration = const Duration(seconds: 4),
  }) {
    return show(
      context,
      message: message,
      variant: TwoGoSnackbarVariant.connectivity,
      duration: duration,
      showProgress: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (variant == TwoGoSnackbarVariant.connectivity) {
      return _ConnectivityToast(message: message, icon: icon);
    }

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
      case TwoGoSnackbarVariant.connectivity:
        indicatorColor = TwoGoColors.feedbackInfo;
        defaultIconData = TwoGoIcons.info;
        break;
    }

    final leadingWidget =
        icon ??
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: indicatorColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(defaultIconData, size: 14, color: TwoGoColors.neutral0),
        );

    return ClipRRect(
      borderRadius: TwoGoRadius.borderMedium,
      child: ColoredBox(
        color: TwoGoColors.toastBackground,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: TwoGoSpacing.md,
                vertical: TwoGoSpacing.sm,
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
            ),
            if (progressDuration != null)
              _ToastProgressBar(
                color: indicatorColor,
                duration: progressDuration!,
              ),
          ],
        ),
      ),
    );
  }
}

class _ConnectivityToast extends StatelessWidget {
  const _ConnectivityToast({required this.message, this.icon});

  final String message;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: TwoGoRadius.borderMedium,
      child: ColoredBox(
        color: TwoGoColors.toastConnectivity,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: TwoGoSpacing.md,
            vertical: TwoGoSpacing.sm + 2,
          ),
          child: Row(
            children: [
              icon ??
                  const Icon(
                    TwoGoIcons.satellite,
                    size: 22,
                    color: TwoGoColors.contentPrimary,
                  ),
              const SizedBox(width: TwoGoSpacing.sm),
              Expanded(
                child: Text(
                  message,
                  style: TwoGoTypography.bodyMedium.copyWith(
                    color: TwoGoColors.contentPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToastProgressBar extends StatefulWidget {
  const _ToastProgressBar({required this.color, required this.duration});

  final Color color;
  final Duration duration;

  @override
  State<_ToastProgressBar> createState() => _ToastProgressBarState();
}

class _ToastProgressBarState extends State<_ToastProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return LinearProgressIndicator(
          value: 1.0 - _controller.value,
          minHeight: 3,
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation<Color>(widget.color),
        );
      },
    );
  }
}
