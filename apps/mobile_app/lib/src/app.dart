import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

class TwoGoApp extends StatelessWidget {
  final String environment;

  const TwoGoApp({super.key, required this.environment});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2GO ($environment)',
      theme: TwoGoTheme.light,
      home: Scaffold(
        appBar: TwoGoAppBar(
          title: '2GO App - $environment',
          showBackButton: false,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(TwoGoSpacing.md),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome to 2GO Mobile ($environment)',
                  style: TwoGoTypography.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: TwoGoSpacing.md),
                TwoGoButton(text: 'Explore Trips', onPressed: () {}),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
