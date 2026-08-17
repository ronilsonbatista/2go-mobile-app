import 'package:flutter/material.dart';
import '../../tokens/spacing.dart';

/// A responsive layout wrapper that applies horizontal padding and a [maxWidth] constraint.
class TwoGoCenteredContent extends StatelessWidget {
  const TwoGoCenteredContent({
    required this.child,
    super.key,
    this.maxWidth = 300.0,
    this.padding = const EdgeInsets.symmetric(horizontal: TwoGoSpacing.lg),
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
  }
}
