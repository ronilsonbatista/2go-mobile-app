import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_design_system/design_system.dart';

void main() {
  group('TwoGoTextField Widget & Golden Tests', () {
    testWidgets('renders label, hint, and accepts user input', (tester) async {
      String typedText = '';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TwoGoTextField(
              label: 'Entrar com e-mail',
              hint: 'seu.email@gmail.com',
              onChanged: (val) => typedText = val,
            ),
          ),
        ),
      );

      expect(find.text('Entrar com e-mail'), findsOneWidget);
      expect(find.text('seu.email@gmail.com'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'teste@2go.com');
      expect(typedText, 'teste@2go.com');
    });

    testWidgets('renders error text when errorText is provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TwoGoTextField(label: 'E-mail', errorText: 'E-mail inválido'),
          ),
        ),
      );

      expect(find.text('E-mail inválido'), findsOneWidget);
    });

    testWidgets('Golden Test - TwoGoTextField Focused State', (tester) async {
      final focusNode = FocusNode();
      await tester.pumpWidget(
        MaterialApp(
          theme: TwoGoTheme.light,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 320,
                child: TwoGoTextField(
                  label: 'E-mail',
                  hint: 'seu.email@gmail.com',
                  focusNode: focusNode,
                ),
              ),
            ),
          ),
        ),
      );

      focusNode.requestFocus();
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(TwoGoTextField),
        matchesGoldenFile('goldens/twogo_text_field_focused.png'),
      );
    });
  });

  group('TwoGoOtpField Widget & Golden Tests', () {
    testWidgets(
      'renders 6 boxes and triggers onCompleted callback when filled',
      (tester) async {
        String completedCode = '';
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TwoGoOtpField(
                length: 6,
                onCompleted: (code) => completedCode = code,
              ),
            ),
          ),
        );

        expect(find.byType(TextField), findsNWidgets(6));

        final textFields = find.byType(TextField);
        for (int i = 0; i < 6; i++) {
          await tester.enterText(textFields.at(i), '${i + 1}');
        }
        await tester.pump();

        expect(completedCode, '123456');
      },
    );

    testWidgets('Golden Test - TwoGoOtpField Error State', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: TwoGoTheme.light,
          home: const Scaffold(
            body: Center(
              child: SizedBox(
                width: 340,
                child: TwoGoOtpField(length: 6, value: '120434', error: true),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(TwoGoOtpField),
        matchesGoldenFile('goldens/twogo_otp_field_error.png'),
      );
    });
  });
}
