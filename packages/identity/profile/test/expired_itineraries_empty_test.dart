import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_design_system/design_system.dart';
import 'package:twogo_profile/profile.dart';

void main() {
  testWidgets('Roteiros expirados shows empty state without SP/Paris stubs', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: TwoGoTheme.light,
        home: const ExpiredItinerariesPage(),
      ),
    );
    await tester.pump();

    expect(find.text('São Paulo'), findsNothing);
    expect(find.text('Paris'), findsNothing);
    expect(
      find.text('Não temos roteiros expirados por aqui.'),
      findsOneWidget,
    );
  });

  testWidgets('Roteiros expirados still renders provided items', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: TwoGoTheme.light,
        home: ExpiredItinerariesPage(
          items: ExpiredItinerary.designDemos,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('São Paulo'), findsOneWidget);
    expect(find.text('Paris'), findsOneWidget);
  });
}
