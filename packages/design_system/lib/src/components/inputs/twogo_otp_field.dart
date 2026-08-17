import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../tokens/colors.dart';
import '../../tokens/radius.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';

/// OTP Field component for 2GO Mobile Design System.
///
/// Pure visual input primitive for multi-digit code entry (e.g. 6 boxes).
/// Does NOT contain business rules or API calls.
class TwoGoOtpField extends StatefulWidget {
  final int length;
  final String value;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final bool enabled;
  final bool error;
  final bool isSuccess;
  final bool autofocus;

  const TwoGoOtpField({
    super.key,
    this.length = 6,
    this.value = '',
    this.onChanged,
    this.onCompleted,
    this.enabled = true,
    this.error = false,
    this.isSuccess = false,
    this.autofocus = true,
  });

  @override
  State<TwoGoOtpField> createState() => _TwoGoOtpFieldState();
}

class _TwoGoOtpFieldState extends State<TwoGoOtpField> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _initControllersAndNodes();
  }

  void _initControllersAndNodes() {
    _controllers = List.generate(widget.length, (index) {
      final initialChar = index < widget.value.length
          ? widget.value[index]
          : '';
      return TextEditingController(text: initialChar);
    });

    _focusNodes = List.generate(widget.length, (index) {
      final node = FocusNode();
      node.addListener(() => setState(() {}));
      return node;
    });
  }

  @override
  void didUpdateWidget(covariant TwoGoOtpField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.length != widget.length) {
      _disposeControllersAndNodes();
      _initControllersAndNodes();
    } else if (oldWidget.value != widget.value) {
      for (int i = 0; i < widget.length; i++) {
        final char = i < widget.value.length ? widget.value[i] : '';
        if (_controllers[i].text != char) {
          _controllers[i].text = char;
        }
      }
    }
  }

  void _disposeControllersAndNodes() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
  }

  @override
  void dispose() {
    _disposeControllersAndNodes();
    super.dispose();
  }

  void _onCellChanged(int index, String value) {
    if (value.length > 1) {
      // User pasted code into field
      final digits = value.replaceAll(RegExp(r'\D'), '');
      var currentCode = '';
      for (int i = 0; i < widget.length; i++) {
        final char = i < digits.length ? digits[i] : '';
        _controllers[i].text = char;
        currentCode += char;
      }
      if (digits.length >= widget.length) {
        _focusNodes[widget.length - 1].requestFocus();
      } else {
        _focusNodes[digits.length].requestFocus();
      }
      widget.onChanged?.call(currentCode);
      if (currentCode.length == widget.length) {
        widget.onCompleted?.call(currentCode);
      }
      return;
    }

    if (value.isNotEmpty) {
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      }
    }

    final code = _controllers.map((c) => c.text).join();
    widget.onChanged?.call(code);

    if (code.length == widget.length) {
      widget.onCompleted?.call(code);
    }
  }

  void _onKeyDown(int index, RawKeyEvent event) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty && index > 0) {
        _focusNodes[index - 1].requestFocus();
        _controllers[index - 1].clear();
        final code = _controllers.map((c) => c.text).join();
        widget.onChanged?.call(code);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(widget.length, (index) {
        final isFocused = _focusNodes[index].hasFocus;

        Color borderColor = TwoGoColors.borderDefault;
        Color fillColor = TwoGoColors.surfaceSecondary;

        if (!widget.enabled) {
          borderColor = TwoGoColors.surfaceDisabled;
          fillColor = TwoGoColors.surfaceDisabled;
        } else if (widget.error) {
          borderColor = TwoGoColors.borderError;
          fillColor = TwoGoColors.errorLight.withValues(alpha: 0.4);
        } else if (widget.isSuccess) {
          borderColor = TwoGoColors.borderSuccess;
          fillColor = TwoGoColors.successLight.withValues(alpha: 0.4);
        } else if (isFocused) {
          borderColor = TwoGoColors.borderFocused;
          fillColor = TwoGoColors.surfacePrimary;
        }

        return Flexible(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: TwoGoSpacing.xxs),
            height: 48,
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: TwoGoRadius.borderMedium,
              border: Border.all(
                color: borderColor,
                width: isFocused || widget.error || widget.isSuccess
                    ? 1.5
                    : 1.0,
              ),
            ),
            alignment: Alignment.center,
            child: RawKeyboardListener(
              focusNode: FocusNode(),
              onKey: (event) => _onKeyDown(index, event),
              child: TextField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                enabled: widget.enabled,
                autofocus: widget.autofocus && index == 0,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: TwoGoTypography.headlineSmall.copyWith(
                  color: widget.error
                      ? TwoGoColors.feedbackError
                      : (widget.enabled
                            ? TwoGoColors.contentPrimary
                            : TwoGoColors.contentDisabled),
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (val) => _onCellChanged(index, val),
              ),
            ),
          ),
        );
      }),
    );
  }
}
