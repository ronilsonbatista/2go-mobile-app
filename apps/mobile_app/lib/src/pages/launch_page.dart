import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

class LaunchPage extends StatelessWidget {
  const LaunchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: TwoGoColors.backgroundPrimary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TwoGoLoadingIndicator(size: 36),
            SizedBox(height: TwoGoSpacing.md),
            Text(
              'Restaurando sessão 2GO...',
              style: TwoGoTypography.labelMedium,
            ),
          ],
        ),
      ),
    );
  }
}
