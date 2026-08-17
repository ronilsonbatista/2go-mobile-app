import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

/// Feature-local layout constants for 2GO Authentication flow.
abstract class AuthLayout {
  /// Maximum content width constraint on 390px canonical viewport (296–300px)
  static const double contentMaxWidth = 300.0;

  /// Horizontal padding on canonical viewport
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: TwoGoSpacing.xl,
  );

  /// Vertical spacing from title to email input label
  static const double titleToFormSpacing = 72.0;

  /// Vertical spacing from input to main CTA button
  static const double fieldToButtonSpacing = 24.0;

  /// Vertical spacing from main CTA button to social login section
  static const double socialSectionSpacing = 48.0;

  /// OTP cell dimensions & gap
  static const double otpCellWidth = 40.0;
  static const double otpCellHeight = 44.0;
  static const double otpCellGap = 8.0;

  /// Vertical spacing from OTP inputs to CTA button
  static const double otpToButtonSpacing = 24.0;

  /// Vertical spacing from CTA button to resend/countdown pill
  static const double buttonToResendSpacing = 16.0;
}
