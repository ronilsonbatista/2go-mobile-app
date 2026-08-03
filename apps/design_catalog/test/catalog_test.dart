import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_design_catalog/main.dart';

void main() {
  testWidgets('Renders 2GO Design Catalog', (WidgetTester tester) async {
    await tester.pumpWidget(const TwoGoCatalogApp());
    expect(find.text('2GO Design Catalog'), findsOneWidget);
  });
}
