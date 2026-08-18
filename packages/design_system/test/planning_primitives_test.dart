import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_design_system/design_system.dart';

void main() {
  group('TwoGoProgressBar Unit & Widget Tests', () {
    testWidgets('renders progress correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: TwoGoProgressBar(progress: 0.5)),
        ),
      );

      expect(find.byType(TwoGoProgressBar), findsOneWidget);
    });
  });

  group('TwoGoCounter Unit & Widget Tests', () {
    testWidgets('renders label and value', (WidgetTester tester) async {
      int count = 2;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TwoGoCounter(
              label: 'Adultos',
              subtitle: '18 anos ou mais',
              value: count,
              onChanged: (val) => count = val,
            ),
          ),
        ),
      );

      expect(find.text('Adultos'), findsOneWidget);
      expect(find.text('18 anos ou mais'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('increments and decrements correctly', (
      WidgetTester tester,
    ) async {
      int count = 2;
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: TwoGoCounter(
                  label: 'Adultos',
                  value: count,
                  min: 1,
                  max: 5,
                  onChanged: (val) {
                    setState(() {
                      count = val;
                    });
                  },
                ),
              ),
            );
          },
        ),
      );

      final addBtn = find.byIcon(TwoGoIcons.add);
      final removeBtn = find.byIcon(TwoGoIcons.remove);

      await tester.tap(addBtn);
      await tester.pumpAndSettle();
      expect(count, 3);

      await tester.tap(removeBtn);
      await tester.pumpAndSettle();
      expect(count, 2);
    });
  });
}
