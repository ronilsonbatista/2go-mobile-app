import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radius.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';

/// Text Field component for 2GO Mobile Design System.
class TwoGoTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final Widget? prefix;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final bool readOnly;
  final int maxLines;
  final bool autofocus;
  final bool isSuccess;

  TwoGoTextField({
    super.key,
    this.label,
    String? hint,
    String? hintText,
    this.helperText,
    this.errorText,
    Widget? prefix,
    IconData? prefixIcon,
    this.suffix,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.autofocus = false,
    this.isSuccess = false,
  }) : hint = hint ?? hintText,
       prefix =
           prefix ??
           (prefixIcon != null
               ? Icon(prefixIcon, color: TwoGoColors.contentSecondary)
               : null);

  @override
  State<TwoGoTextField> createState() => _TwoGoTextFieldState();
}

class _TwoGoTextFieldState extends State<TwoGoTextField> {
  late FocusNode _effectiveFocusNode;

  @override
  void initState() {
    super.initState();
    _effectiveFocusNode = widget.focusNode ?? FocusNode();
    _effectiveFocusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _effectiveFocusNode.dispose();
    } else {
      _effectiveFocusNode.removeListener(_handleFocusChange);
    }
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final isFocused = _effectiveFocusNode.hasFocus;

    Color borderColor = TwoGoColors.borderDefault;
    Color fillColor = TwoGoColors.surfaceSecondary;

    if (!widget.enabled) {
      borderColor = TwoGoColors.surfaceDisabled;
      fillColor = TwoGoColors.surfaceDisabled;
    } else if (hasError) {
      borderColor = TwoGoColors.borderError;
      fillColor = TwoGoColors.errorLight.withValues(alpha: 0.3);
    } else if (widget.isSuccess) {
      borderColor = TwoGoColors.borderSuccess;
      fillColor = TwoGoColors.successLight.withValues(alpha: 0.3);
    } else if (isFocused) {
      borderColor = TwoGoColors.borderFocused;
      fillColor = TwoGoColors.surfacePrimary;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: TwoGoTypography.labelMedium.copyWith(
              color: widget.enabled
                  ? TwoGoColors.contentPrimary
                  : TwoGoColors.contentDisabled,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: TwoGoSpacing.xxs),
        ],
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: TwoGoRadius.borderMedium,
            border: Border.all(
              color: borderColor,
              width: isFocused || hasError || widget.isSuccess ? 1.5 : 1.0,
            ),
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _effectiveFocusNode,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            maxLines: widget.maxLines,
            autofocus: widget.autofocus,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            style: TwoGoTypography.bodyMedium.copyWith(
              color: widget.enabled
                  ? TwoGoColors.contentPrimary
                  : TwoGoColors.contentDisabled,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TwoGoTypography.bodyMedium.copyWith(
                color: TwoGoColors.contentSecondary,
              ),
              prefixIcon: widget.prefix,
              suffixIcon: widget.suffix,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: TwoGoSpacing.md,
                vertical: TwoGoSpacing.sm,
              ),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: TwoGoSpacing.xxs),
          Text(
            widget.errorText!,
            style: TwoGoTypography.labelSmall.copyWith(
              color: TwoGoColors.feedbackError,
            ),
          ),
        ] else if (widget.helperText != null) ...[
          const SizedBox(height: TwoGoSpacing.xxs),
          Text(
            widget.helperText!,
            style: TwoGoTypography.labelSmall.copyWith(
              color: TwoGoColors.contentSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
