import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radius.dart';

class TwoGoProgressBar extends StatelessWidget {
  final double progress;
  final double height;
  final Color? activeColor;
  final Color? backgroundColor;
  final BorderRadiusGeometry? borderRadius;

  const TwoGoProgressBar({
    super.key,
    required this.progress,
    this.height = 4.0,
    this.activeColor,
    this.backgroundColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    final effectiveActiveColor = activeColor ?? TwoGoColors.brandLime;
    final effectiveBgColor = backgroundColor ?? TwoGoColors.neutral200;
    final effectiveRadius = borderRadius ?? TwoGoRadius.borderFull;

    return Semantics(
      value: '${(clampedProgress * 100).round()}%',
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: effectiveBgColor,
          borderRadius: effectiveRadius,
        ),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: clampedProgress,
          child: Container(
            decoration: BoxDecoration(
              color: effectiveActiveColor,
              borderRadius: effectiveRadius,
            ),
          ),
        ),
      ),
    );
  }
}
