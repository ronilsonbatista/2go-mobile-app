import 'package:flutter/material.dart';

/// Design System Color Tokens for 2GO Mobile.
///
/// Features primitive colors and semantic color mappings reflecting the
/// visual identity from official product references.
abstract class TwoGoColors {
  // ---------------------------------------------------------------------------
  // PRIMITIVE COLORS
  // ---------------------------------------------------------------------------

  /// Primary Brand Action Lime Green (from reference prints)
  static const Color brandLime = Color(0xFFC4E000);

  /// Darkened Lime Green for pressed state
  static const Color brandLimePressed = Color(0xFFAEC700);

  /// Light Lime tint for backgrounds
  static const Color brandLimeLight = Color(0xFFF4FA80);

  /// Neutral Palette
  static const Color neutral0 = Color(0xFFFFFFFF);
  static const Color neutral50 = Color(0xFFF8F9FA);
  static const Color neutral100 = Color(0xFFF3F4F6);
  static const Color neutral200 = Color(0xFFE5E7EB);
  static const Color neutral300 = Color(0xFFD1D5DB);
  static const Color neutral400 = Color(0xFF9CA3AF);
  static const Color neutral500 = Color(0xFF6B7280);
  static const Color neutral600 = Color(0xFF4B5563);
  static const Color neutral700 = Color(0xFF374151);
  static const Color neutral800 = Color(0xFF1F2937);
  static const Color neutral900 = Color(0xFF111827);

  /// Feedback Primitives
  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFFDCFCE7);

  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEE2E2);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);

  static const Color info = Color(0xFF2563EB);
  static const Color infoLight = Color(0xFFDBEAFE);

  // ---------------------------------------------------------------------------
  // SEMANTIC COLORS
  // ---------------------------------------------------------------------------

  /// Backgrounds
  static const Color backgroundPrimary = neutral0;
  static const Color backgroundSecondary = neutral50;

  /// Surfaces
  static const Color surfacePrimary = neutral0;
  static const Color surfaceSecondary = neutral100;
  static const Color surfaceDisabled = neutral200;

  /// Content / Typography
  static const Color contentPrimary = neutral900;
  static const Color contentSecondary = neutral500;
  static const Color contentDisabled = neutral400;
  static const Color contentInverse = neutral0;

  /// Borders
  static const Color borderDefault = neutral200;
  static const Color borderFocused = brandLime;
  static const Color borderError = error;
  static const Color borderSuccess = success;

  /// Primary Actions
  static const Color actionPrimary = brandLime;
  static const Color actionPrimaryPressed = brandLimePressed;
  static const Color actionPrimaryDisabled = neutral200;

  /// Secondary Actions
  static const Color actionSecondary = neutral100;
  static const Color actionSecondaryPressed = neutral200;

  /// Feedbacks
  static const Color feedbackSuccess = success;
  static const Color feedbackWarning = warning;
  static const Color feedbackError = error;
  static const Color feedbackInfo = info;

  /// Overlay / Toast / Toast Background
  static const Color toastBackground = neutral900;

  // Legacy alias getters for backwards compatibility
  static Color get primary => actionPrimary;
  static Color get background => backgroundPrimary;
}
