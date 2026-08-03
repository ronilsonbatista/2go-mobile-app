import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_mobile_app/src/app.dart';

void main() {
  testWidgets('Renders 2GO main app widget', (WidgetTester tester) async {
    await tester.pumpWidget(const TwoGoApp(environment: 'development'));
    expect(find.textContaining('2GO App - development'), findsOneWidget);
  });
}
