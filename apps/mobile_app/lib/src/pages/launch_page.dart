import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

/// Session-restore / cold-start surface.
/// Visual source of truth: Figma Splash — white background, centered "2go" mark.
class LaunchPage extends StatelessWidget {
  const LaunchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: TwoGoColors.backgroundPrimary,
      body: SafeArea(
        child: Center(
          child: _TwoGoSplashMark(),
        ),
      ),
    );
  }
}

class _TwoGoSplashMark extends StatelessWidget {
  const _TwoGoSplashMark();

  @override
  Widget build(BuildContext context) {
    // Figma: centered circular mark with lowercase "2go" wordmark.
    // No stroke/fill invented beyond white surface + typography.
    return SizedBox(
      width: 120,
      height: 120,
      child: Center(
        child: Text(
          '2go',
          style: TwoGoTypography.display.copyWith(
            fontWeight: FontWeight.w700,
            color: TwoGoColors.contentPrimary,
            letterSpacing: -0.8,
            height: 1,
          ),
        ),
      ),
    );
  }
}
