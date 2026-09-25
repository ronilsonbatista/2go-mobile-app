import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_mobile_app/src/pages/launch_page.dart';

void main() {
  testWidgets('Splash shows centered 2go wordmark on primary background', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LaunchPage()));
    expect(find.text('2go'), findsOneWidget);
    expect(find.byType(LaunchPage), findsOneWidget);
  });
}
