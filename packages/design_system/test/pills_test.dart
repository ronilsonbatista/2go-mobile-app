import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_design_system/design_system.dart';

void main() {
  group('TwoGoPill Widget & Golden Tests', () {
    testWidgets('renders label and responds to tap', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: TwoGoPill(
                label: 'Aguarde 60 seg',
                onTap: () => tapped = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Aguarde 60 seg'), findsOneWidget);
      await tester.tap(find.byType(TwoGoPill));
      expect(tapped, isTrue);
    });

    testWidgets('Golden Test - TwoGoPill Neutral State', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: TwoGoPill(
                label: 'Aguarde 20 seg',
                variant: TwoGoPillVariant.neutral,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Aguarde 20 seg'), findsOneWidget);
    });

    testWidgets('Golden Test - TwoGoPill Outlined Active State', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: TwoGoPill(
                label: 'Reenviar código',
                variant: TwoGoPillVariant.outlined,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Reenviar código'), findsOneWidget);
    });
  });
}
