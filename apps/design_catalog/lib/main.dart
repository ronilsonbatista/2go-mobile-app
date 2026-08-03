import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

void main() {
  runApp(const TwoGoCatalogApp());
}

class TwoGoCatalogApp extends StatelessWidget {
  const TwoGoCatalogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2GO Design System Catalog',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('2GO Design Catalog'),
          backgroundColor: TwoGoColors.primary,
          foregroundColor: Colors.white,
        ),
        body: ListView(
          padding: const EdgeInsets.all(TwoGoSpacing.md),
          children: [
            const Text(
              'Typography - Heading 1',
              style: TwoGoTypography.heading1,
            ),
            const SizedBox(height: TwoGoSpacing.sm),
            const Text('Typography - Body Text', style: TwoGoTypography.body),
            const SizedBox(height: TwoGoSpacing.md),
            TwoGoButton(label: 'TwoGo Primary Button', onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
