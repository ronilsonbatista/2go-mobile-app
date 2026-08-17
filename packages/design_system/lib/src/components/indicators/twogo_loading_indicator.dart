import 'package:flutter/material.dart';
import '../../tokens/colors.dart';

/// Loading Indicator component for 2GO Mobile Design System.
class TwoGoLoadingIndicator extends StatelessWidget {
  final double size;
  final Color color;
  final double strokeWidth;

  const TwoGoLoadingIndicator({
    super.key,
    this.size = 24.0,
    this.color = TwoGoColors.neutral900,
    this.strokeWidth = 2.5,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}
