import 'package:flutter/material.dart';

/// Semantic Icon mappings for 2GO Mobile Design System.
///
/// Wraps standard Material/SF icons with semantic names corresponding
/// to the visual patterns in the reference prints.
abstract class TwoGoIcons {
  static const IconData back = Icons.chevron_left_rounded;
  static const IconData close = Icons.close_rounded;
  static const IconData check = Icons.check_rounded;
  static const IconData checkCircle = Icons.check_circle_rounded;
  static const IconData error = Icons.error_rounded;
  static const IconData warning = Icons.warning_amber_rounded;
  static const IconData info = Icons.info_outline_rounded;
  static const IconData chevronRight = Icons.chevron_right_rounded;

  // Payments / Commerce primitives
  static const IconData creditCard = Icons.credit_card_rounded;
  static const IconData pix = Icons.qr_code_rounded;
  static const IconData apple = Icons.apple;
  static const IconData google = Icons.g_mobiledata_rounded;
  static const IconData facebook = Icons.facebook_rounded;
  static const IconData copy = Icons.content_copy_rounded;

  // Input actions
  static const IconData visibility = Icons.visibility_outlined;
  static const IconData visibilityOff = Icons.visibility_off_outlined;
}
