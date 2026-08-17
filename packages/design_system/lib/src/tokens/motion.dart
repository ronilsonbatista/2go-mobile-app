import 'package:flutter/animation.dart';

/// Design System Motion Tokens for 2GO Mobile.
///
/// Smooth, subtle, and functional micro-animations for high-end feel.
abstract class TwoGoMotion {
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 250);
  static const Duration durationSlow = Duration(milliseconds: 350);

  static const Curve curveStandard = Curves.easeInOut;
  static const Curve curveEmphasized = Curves.fastOutSlowIn;
}
