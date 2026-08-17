import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/spacing.dart';

/// Divider component for 2GO Mobile Design System.
class TwoGoDivider extends StatelessWidget {
  final double thickness;
  final double space;
  final Color color;

  const TwoGoDivider({
    super.key,
    this.thickness = 1.0,
    this.space = TwoGoSpacing.md,
    this.color = TwoGoColors.borderDefault,
  });

  @override
  Widget build(BuildContext context) {
    return Divider(thickness: thickness, height: space, color: color);
  }
}
