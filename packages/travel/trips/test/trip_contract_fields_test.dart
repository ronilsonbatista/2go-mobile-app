import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_trips/trips.dart';

void main() {
  test('GET /trips/:id keeps phase 1 and 2 fields and leaves gaps null', () {
    final trip = TripDto.fromJson({
      'id': 'trip-1',
      'userId': 'user-1',
      'title': 'Lisboa',
      'destination': 'Lisboa',
      'arrivalDateTime': '2026-10-01T14:30:00.000Z',
      'departureDateTime': '2026-10-10T18:00:00.000Z',
      'usedSwapsCount': 1,
      'allowedSwapsCount': 4,
      'accommodation': {
        'id': 'stay-1',
        'name': 'Hotel do Chiado',
        'address': 'Rua Garrett',
        'neighborhood': 'Chiado',
        'checkInDateTime': '2026-10-01T15:00:00.000Z',
        'checkOutDateTime': '2026-10-10T11:00:00.000Z',
        'latitude': 38.71,
        'longitude': -9.14,
      },
      'days': [
        {
          'id': 'day-1',
          'tripId': 'trip-1',
          'dayNumber': 1,
          'items': [
            {
              'id': 'first',
              'tripDayId': 'day-1',
              'title': 'Miradouro',
              'category': 'TOURIST_ATTRACTION',
              'order': 1,
              'ticketStatus': 'FREE',
              'transitMode': 'WALKING',
            },
            {
              'id': 'second',
              'tripDayId': 'day-1',
              'title': 'Castelo',
              'category': 'TOURIST_ATTRACTION',
              'order': 2,
              'ticketStatus': 'TICKET_REQUIRED',
              'transitDistanceMeters': 1500,
              'transitDurationMinutes': 12,
              'transitMode': 'WALKING',
            },
          ],
        },
      ],
    }).toEntity();

    expect(trip.arrivalDateTime, DateTime.parse('2026-10-01T14:30:00.000Z'));
    expect(trip.departureDateTime, DateTime.parse('2026-10-10T18:00:00.000Z'));
    expect(trip.usedSwapsCount, 1);
    expect(trip.allowedSwapsCount, 4);
    expect(trip.accommodation?.name, 'Hotel do Chiado');
    expect(trip.accommodation?.neighborhood, 'Chiado');

    final first = trip.days.single.items.firstWhere((item) => item.order == 1);
    expect(first.ticketStatus, 'FREE');
    expect(first.transitDistanceMeters, isNull);
    expect(first.transitDurationMinutes, isNull);
    expect(
      TripItineraryView.transitLabel(
        meters: first.transitDistanceMeters,
        minutes: first.transitDurationMinutes,
        mode: first.transitMode,
      ),
      isNull,
    );

    final second = trip.days.single.items.firstWhere((item) => item.order == 2);
    expect(second.ticketStatus, 'TICKET_REQUIRED');
    expect(second.transitDistanceMeters, 1500);
    expect(second.transitDurationMinutes, 12);

    final bare = TripDto.fromJson({
      'id': 'trip-2',
      'title': 'Sem extras',
      'destination': 'Porto',
      'days': [
        {
          'id': 'day-1',
          'dayNumber': 1,
          'items': [
            {'id': 'only', 'title': 'Café', 'order': 1},
          ],
        },
      ],
    }).toEntity();
    expect(bare.arrivalDateTime, isNull);
    expect(bare.departureDateTime, isNull);
    expect(bare.usedSwapsCount, isNull);
    expect(bare.allowedSwapsCount, isNull);
    expect(bare.accommodation, isNull);
    expect(bare.days.single.items.single.ticketStatus, isNull);
    expect(bare.days.single.items.single.transitDistanceMeters, isNull);
    expect(bare.days.single.items.single.transitDurationMinutes, isNull);
  });

  testWidgets('paid trip shows contract fields and no phase 3 actions', (
    tester,
  ) async {
    final trip = TripDto.fromJson({
      'id': 'trip-1',
      'userId': 'user-1',
      'title': 'Lisboa',
      'destination': 'Lisboa',
      'arrivalDateTime': '2026-10-01T14:30:00.000Z',
      'departureDateTime': '2026-10-10T18:00:00.000Z',
      'usedSwapsCount': 1,
      'allowedSwapsCount': 4,
      'accommodation': {
        'id': 'stay-1',
        'name': 'Hotel do Chiado',
        'address': 'Rua Garrett',
        'checkInDateTime': '2026-10-01T15:00:00.000Z',
        'latitude': 38.71,
        'longitude': -9.14,
      },
      'days': [
        {
          'id': 'day-1',
          'dayNumber': 1,
          'items': [
            {
              'id': 'first',
              'title': 'Miradouro',
              'order': 1,
              'ticketStatus': 'FREE',
            },
            {
              'id': 'second',
              'title': 'Castelo',
              'order': 2,
              'ticketStatus': 'TICKET_REQUIRED',
              'transitDistanceMeters': 1500,
              'transitDurationMinutes': 12,
              'transitMode': 'WALKING',
            },
          ],
        },
      ],
    }).toEntity();

    await tester.pumpWidget(MaterialApp(home: TripItineraryView(trip: trip)));

    expect(
      find.text(
        'Chegada: ${TripItineraryView.formatDateTime(trip.arrivalDateTime!)}',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Partida: ${TripItineraryView.formatDateTime(trip.departureDateTime!)}',
      ),
      findsOneWidget,
    );
    expect(find.text('Trocas: 1 de 4'), findsOneWidget);
    expect(find.text('Hospedagem'), findsOneWidget);
    expect(find.text('Hotel do Chiado'), findsOneWidget);
    expect(find.text('Gratuito'), findsOneWidget);
    expect(find.text('Ingresso necessário'), findsOneWidget);
    expect(find.text('1.5 km · 12 min · a pé'), findsOneWidget);
    expect(find.text('Substituir'), findsNothing);
    expect(find.text('Sugestões de refeição'), findsNothing);
    expect(find.text('Adicionar hospedagem'), findsNothing);
  });

  testWidgets('missing transit and lodging stay off the screen', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: TripItineraryView(
          trip: TripEntity(
            id: 'trip-2',
            userId: 'user-1',
            title: 'Porto',
            destination: 'Porto',
            days: [
              TripDayEntity(
                id: 'day-1',
                tripId: 'trip-2',
                dayNumber: 1,
                items: [
                  ItineraryItemEntity(
                    id: 'cafe',
                    tripDayId: 'day-1',
                    title: 'Café',
                    order: 1,
                    transitMode: 'WALKING',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Hospedagem'), findsNothing);
    expect(find.text('Trocas: 0 de 4'), findsNothing);
    expect(find.textContaining('a pé'), findsNothing);
    expect(find.text('Ingresso não informado'), findsNothing);
  });
}
