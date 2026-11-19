import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_planning/twogo_planning.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget wrap(Widget child) {
    return MaterialApp(home: Scaffold(body: Center(child: child)));
  }

  testWidgets('null iconUrl shows outlined location pin (not empty)', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const PlaceThumb()));
    expect(find.byIcon(Icons.location_on_outlined), findsOneWidget);
  });

  testWidgets('Core city.svg iconUrl maps to tinted location pin', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const PlaceThumb(
          iconUrl:
              'https://core-api.example/static/place-icons/city.svg',
        ),
      ),
    );
    expect(find.byIcon(Icons.location_on), findsOneWidget);
    expect(find.byIcon(Icons.location_on_outlined), findsNothing);
  });

  testWidgets('region.svg does not mis-detect as place via place-icons path', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const PlaceThumb(
          iconUrl:
              'http://core-api.example/static/place-icons/region.svg',
        ),
      ),
    );
    final icon = tester.widget<Icon>(find.byIcon(Icons.location_on));
    expect(icon.color, const Color(0xFF7C3AED));
  });
}
