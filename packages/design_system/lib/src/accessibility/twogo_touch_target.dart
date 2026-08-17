import 'package:flutter/material.dart';
import '../tokens/sizing.dart';

/// Accessibility helper to enforce minimum 48x48 touch targets on mobile.
class TwoGoTouchTarget extends StatelessWidget {
  final Widget child;
  final double minWidth;
  final double minHeight;

  const TwoGoTouchTarget({
    super.key,
    required this.child,
    this.minWidth = TwoGoSizing.touchTargetMin,
    this.minHeight = TwoGoSizing.touchTargetMin,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: minWidth, minHeight: minHeight),
      child: Center(widthFactor: 1.0, heightFactor: 1.0, child: child),
    );
  }
}
