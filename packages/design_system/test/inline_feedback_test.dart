import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_design_system/design_system.dart';

void main() {
  group('TwoGoInlineFeedback Widget Tests', () {
    testWidgets('renders message with error icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: TwoGoInlineFeedback(
                message: 'Verifique o código e tente novamente!',
                variant: TwoGoInlineFeedbackVariant.error,
              ),
            ),
          ),
        ),
      );

      expect(
        find.text('Verifique o código e tente novamente!'),
        findsOneWidget,
      );
    });
  });
}
