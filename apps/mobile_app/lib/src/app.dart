import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

class TwoGoApp extends StatelessWidget {
  final String environment;

  const TwoGoApp({super.key, required this.environment});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2GO ($environment)',
      theme: ThemeData(
        scaffoldBackgroundColor: TwoGoColors.background,
        colorScheme: ColorScheme.fromSeed(seedColor: TwoGoColors.primary),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('2GO App - $environment'),
          backgroundColor: TwoGoColors.primary,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome to 2GO Mobile ($environment)',
                style: TwoGoTypography.heading1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: TwoGoSpacing.md),
              TwoGoButton(label: 'Explore Trips', onPressed: () {}),
            ],
          ),
        ),
      ),
    );
  }
}
