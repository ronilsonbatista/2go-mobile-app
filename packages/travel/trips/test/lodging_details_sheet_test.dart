import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_trips/trips.dart';

void main() {
  const stay = TripAccommodation(
    id: 'stay-1',
    name: 'Hotel Doria',
    address: 'Piazza del Viminale, 14, 00184 Roma, Itália.',
    latitude: 41.8992,
    longitude: 12.4942,
  );

  testWidgets('hotel modal shows name, address, directions, alterar', (
    tester,
  ) async {
    Uri? opened;
    var changeTaps = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () {
                  showLodgingDetailsFlow(
                    context,
                    stay: stay,
                    kind: PlaceDetailsKind.hotel,
                    onOpenUrl: (uri) => opened = uri,
                    onChangeLodging: () => changeTaps++,
                  );
                },
                child: const Text('Open hotel'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open hotel'));
    await tester.pumpAndSettle();

    expect(find.text('Detalhes'), findsOneWidget);
    expect(find.text('Hotel Doria'), findsOneWidget);
    expect(find.textContaining('Piazza del Viminale'), findsOneWidget);
    expect(find.text('Obter direções'), findsOneWidget);
    expect(find.text('Alterar hospedagem'), findsOneWidget);

    await tester.tap(find.text('Obter direções'));
    await tester.pump();
    expect(opened?.toString(), contains('destination=41.8992,12.4942'));

    await tester.tap(find.text('Alterar hospedagem'));
    await tester.pumpAndSettle();
    expect(changeTaps, 1);
    expect(find.text('Obter direções'), findsNothing);
  });

  testWidgets('end modal omits hotel name, keeps address + alterar', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () {
                  showLodgingDetailsFlow(
                    context,
                    stay: stay,
                    kind: PlaceDetailsKind.endOfDay,
                  );
                },
                child: const Text('Open end'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open end'));
    await tester.pumpAndSettle();

    expect(find.text('Detalhes'), findsOneWidget);
    expect(find.text('Hotel Doria'), findsNothing);
    expect(find.textContaining('Piazza del Viminale'), findsOneWidget);
    expect(find.text('Obter direções'), findsOneWidget);
    expect(find.text('Alterar hospedagem'), findsOneWidget);
  });

  testWidgets('pick-mode placed sheet hides substitute/delete', (tester) async {
    const data = PlaceDetailsViewData(
      displayName: 'Panteão',
      timeLabel: '11:05 - 11:50',
      rating: 4.7,
      priceLevelDisplay: '\$\$',
      durationMinutes: 50,
      recommendedDurationMinutes: 50,
      kind: PlaceDetailsKind.attraction,
      mode: PlaceDetailsMode.pick,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () {
                  PlaceDetailsSheet.show(context, data: data);
                },
                child: const Text('Open sheet'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open sheet'));
    await tester.pumpAndSettle();

    expect(find.text('Mostrar detalhes'), findsOneWidget);
    expect(find.text('Substituir atração'), findsNothing);
    expect(find.text('Excluir'), findsNothing);
  });
}
