import 'package:flutter/material.dart';

/// Design System Elevation Tokens for 2GO Mobile.
///
/// Keeps shadows minimal, clean, and soft matching the product reference design.
abstract class TwoGoElevation {
  static const double none = 0.0;
  static const double low = 2.0;
  static const double medium = 4.0;

  static const List<BoxShadow> shadowLow = [
    BoxShadow(
      color: Color(0x0D000000), // 5% black
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> shadowMedium = [
    BoxShadow(
      color: Color(0x1A000000), // 10% black
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];
}
