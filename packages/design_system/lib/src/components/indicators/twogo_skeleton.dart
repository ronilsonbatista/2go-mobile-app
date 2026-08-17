import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radius.dart';

/// Skeleton loader primitive for placeholder content.
class TwoGoSkeleton extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadiusGeometry borderRadius;

  const TwoGoSkeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius = TwoGoRadius.borderMedium,
  });

  @override
  State<TwoGoSkeleton> createState() => _TwoGoSkeletonState();
}

class _TwoGoSkeletonState extends State<TwoGoSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Container(
            width: widget.width,
            height: widget.height ?? 16,
            decoration: BoxDecoration(
              color: TwoGoColors.neutral200,
              borderRadius: widget.borderRadius,
            ),
          ),
        );
      },
    );
  }
}
