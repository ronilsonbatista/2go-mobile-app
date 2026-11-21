import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_trips/trips.dart';

void main() {
  test('tripToPlanningPreview unlocks every day', () {
    final preview = tripToPlanningPreview(
      TripEntity(
        id: 't1',
        userId: 'u1',
        title: 'Roma',
        destination: 'Roma',
        coverImage: 'https://example.com/roma.jpg',
        premiumUnlockedAt: DateTime.utc(2026, 1, 1),
        startDate: DateTime.utc(2026, 7, 25),
        days: [
          TripDayEntity(
            id: 'd1',
            tripId: 't1',
            dayNumber: 1,
            date: DateTime.utc(2026, 7, 25),
            items: const [
              ItineraryItemEntity(
                id: 'i1',
                tripDayId: 'd1',
                title: 'Coliseu',
                order: 1,
                cost: 0,
              ),
            ],
          ),
          const TripDayEntity(
            id: 'd2',
            tripId: 't1',
            dayNumber: 2,
            items: [],
          ),
        ],
      ),
    );

    expect(preview.lockedDays, isEmpty);
    expect(preview.visibleDays.length, 2);
    expect(preview.visibleDays.first.activities.single.title, 'Coliseu');
    expect(preview.summary.resolvedCoverImageUrl, 'https://example.com/roma.jpg');
  });

  testWidgets('paid preview shows hero chips and never paywalls empty day 2', (
    tester,
  ) async {
    final trip = TripEntity(
      id: 'trip-1',
      userId: 'user-1',
      title: 'Roma',
      destination: 'Roma',
      premiumUnlockedAt: DateTime.utc(2026, 1, 1),
      arrivalDateTime: DateTime.utc(2026, 7, 25, 10),
      days: [
        TripDayEntity(
          id: 'day-1',
          tripId: 'trip-1',
          dayNumber: 1,
          date: DateTime.utc(2026, 7, 25),
          items: const [
            ItineraryItemEntity(
              id: 'a1',
              tripDayId: 'day-1',
              title: 'Piazza Venezia',
              order: 1,
              timeLabel: '08:30 - 10:00',
              cost: 0,
            ),
          ],
        ),
        const TripDayEntity(
          id: 'day-2',
          tripId: 'trip-1',
          dayNumber: 2,
          items: [],
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: PaidTripPreviewView(
          trip: trip,
          initialDayNumber: 1,
          now: () => DateTime.utc(2026, 7, 1, 12),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Editar roteiro'), findsOneWidget);
    expect(find.text('Roma'), findsWidgets);
    expect(find.text('Salvar'), findsOneWidget);
    expect(find.text('Piazza Venezia'), findsOneWidget);
    expect(find.text(TripItineraryView.paywallMessage), findsNothing);

    expect(find.text('Dia 2'), findsOneWidget);
    await tester.tap(find.text('Dia 2'));
    await tester.pump();
    // Empty day stays interactive — no lock card; lodging row remains.
    expect(find.text(TripItineraryView.paywallMessage), findsNothing);
    expect(find.text('Piazza Venezia'), findsNothing);
    expect(find.text('Adicionar hospedagem'), findsOneWidget);
  });
}

