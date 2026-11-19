import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_planning/twogo_planning.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget wrap(Widget child) {
    return MaterialApp(home: Scaffold(body: Center(child: child)));
  }

  testWidgets('null iconUrl without name shows outlined location pin', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const PlaceThumb()));
    expect(find.byIcon(Icons.location_on_outlined), findsOneWidget);
  });

  testWidgets('Roma placeName uses curated monument asset (not pin)', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(const PlaceThumb(placeName: 'Roma')),
    );
    expect(find.byType(Image), findsOneWidget);
    expect(find.byIcon(Icons.location_on_outlined), findsNothing);
    expect(find.byIcon(Icons.location_on), findsNothing);
  });

  testWidgets('Core city.svg with Paris name prefers curated photo', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const PlaceThumb(
          iconUrl: 'https://core-api.example/static/place-icons/city.svg',
          placeName: 'Paris',
        ),
      ),
    );
    expect(find.byType(Image), findsOneWidget);
    expect(find.byIcon(Icons.location_on), findsNothing);
  });

  testWidgets('region.svg without name falls back to tinted pin', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const PlaceThumb(
          iconUrl: 'http://core-api.example/static/place-icons/region.svg',
        ),
      ),
    );
    final icon = tester.widget<Icon>(find.byIcon(Icons.location_on));
    expect(icon.color, const Color(0xFF7C3AED));
  });
}
