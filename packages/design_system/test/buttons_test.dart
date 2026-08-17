import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_design_system/design_system.dart';

void main() {
  group('TwoGoButton Widget & Golden Tests', () {
    testWidgets('triggers onPressed callback when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TwoGoButton(
              text: 'Continuar',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Continuar'), findsOneWidget);
      await tester.tap(find.byType(TwoGoButton));
      expect(tapped, isTrue);
    });

    testWidgets('disabled state does not trigger callback', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: TwoGoButton(text: 'Continuar', onPressed: null)),
        ),
      );

      await tester.tap(find.byType(TwoGoButton));
      expect(tapped, isFalse);
    });

    testWidgets('loading state renders progress indicator', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TwoGoButton(
              text: 'Continuar',
              loading: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(TwoGoLoadingIndicator), findsOneWidget);
    });

    testWidgets('Golden Test - TwoGoButton Primary Variant', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: TwoGoTheme.light,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 320,
                child: TwoGoButton(text: 'Continuar', onPressed: () {}),
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(TwoGoButton),
        matchesGoldenFile('goldens/twogo_button_primary.png'),
      );
    });
  });

  group('TwoGoIconButton Widget Tests', () {
    testWidgets('renders icon and responds to tap', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TwoGoIconButton(
              icon: TwoGoIcons.back,
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.byIcon(TwoGoIcons.back), findsOneWidget);
      await tester.tap(find.byType(TwoGoIconButton));
      expect(tapped, isTrue);
    });
  });
}
