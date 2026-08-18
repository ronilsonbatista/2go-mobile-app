import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_design_system/design_system.dart';

void main() {
  group('TwoGoBadge Widget Tests', () {
    testWidgets('renders dot badge correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: TwoGoBadge(isDot: true))),
        ),
      );

      expect(find.byType(TwoGoBadge), findsOneWidget);
    });

    testWidgets('renders count badge correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: TwoGoBadge(count: 5))),
        ),
      );

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('renders 99+ for count > 99', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: TwoGoBadge(count: 120))),
        ),
      );

      expect(find.text('99+'), findsOneWidget);
    });

    testWidgets('Golden Test - TwoGoBadge', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: TwoGoTheme.light,
          home: const Scaffold(
            body: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TwoGoBadge(isDot: true),
                  SizedBox(width: 8),
                  TwoGoBadge(count: 3),
                  SizedBox(width: 8),
                  TwoGoBadge(count: 150, variant: TwoGoBadgeVariant.brand),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(TwoGoBadge), findsNWidgets(3));
    });
  });
}
