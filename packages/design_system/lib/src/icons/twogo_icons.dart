import 'package:flutter/material.dart';

/// Semantic Icon mappings for 2GO Mobile Design System.
///
/// Wraps standard Material/SF icons with semantic names corresponding
/// to the visual patterns in the reference prints.
abstract class TwoGoIcons {
  static const IconData back = Icons.chevron_left;
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

  // Bottom nav (design asset d3ddcc41): filled house when selected;
  // outlined suitcase / bell / person when idle. Requires app
  // `uses-material-design: true` or glyphs render as tofu / [?].
  static const IconData home = Icons.home;
  static const IconData homeOutlined = Icons.home_outlined;
  // Rolling suitcase (Material luggage) — design d3ddcc41 Viagens.
  // Prefer luggage over card_travel: the briefcase glyph reads as a basket
  // / trash-like shape on iPhone 16 bottom nav (live QA crop).
  static const IconData travel = Icons.luggage;
  static const IconData travelOutlined = Icons.luggage_outlined;
  static const IconData notifications = Icons.notifications;
  static const IconData notificationsOutlined = Icons.notifications_outlined;
  static const IconData profile = Icons.person;
  static const IconData profileOutlined = Icons.person_outline;

  // Counter & Wizard primitives (Age steppers: white circle + black +/−)
  static const IconData add = Icons.add;
  static const IconData remove = Icons.remove;
  static const IconData flight = Icons.flight_takeoff_rounded;
  static const IconData search = Icons.search_rounded;
  static const IconData calendar = Icons.calendar_today_rounded;
  static const IconData clock = Icons.access_time_rounded;
  static const IconData trash = Icons.delete_outline_rounded;
}
