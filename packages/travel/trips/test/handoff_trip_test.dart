import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_trips/trips.dart';

void main() {
  test('GET /trips/:id keeps the item fields the DTO already has', () async {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          expect(options.method, 'GET');
          expect(options.path, '/trips/trip%201');
          handler.resolve(
            Response<Map<String, dynamic>>(
              requestOptions: options,
              data: {
                'id': 'trip 1',
                'userId': 'user-1',
                'title': 'Lisboa',
                'destination': 'Lisboa',
                'days': [
                  {
                    'id': 'day-2',
                    'tripId': 'trip 1',
                    'dayNumber': 2,
                    'items': <Map<String, dynamic>>[],
                  },
                  {
                    'id': 'day-1',
                    'tripId': 'trip 1',
                    'dayNumber': 1,
                    'date': '2026-10-01',
                    'title': 'Chegada',
                    'items': [
                      {
                        'id': 'item-2',
                        'tripDayId': 'day-1',
                        'title': 'Depois',
                        'category': 'BAR',
                        'order': 2,
                        'timeLabel': '21:00',
                        'duration': 90,
                        'cost': 18,
                        'currency': 'EUR',
                        'notes': 'Reservado',
                        'latitude': 38.7,
                        'longitude': -9.1,
                      },
                      {
                        'id': 'item-1',
                        'tripDayId': 'day-1',
                        'title': 'Antes',
                        'category': 'CAFE',
                        'order': 1,
                        'googleMapsLink': 'https://maps.example/cafe',
                      },
                    ],
                  },
                ],
              },
            ),
          );
        },
      ),
    );

    final trip = (await ApiTripsDataSource(
      dio,
    ).getTripById('trip 1')).toEntity();
    final day = trip.days.firstWhere((d) => d.dayNumber == 1);
    final later = day.items.firstWhere((item) => item.order == 2);
    expect(later.timeLabel, '21:00');
    expect(later.duration, 90);
    expect(later.currency, 'EUR');
    expect(later.cost, 18);
    expect(later.notes, 'Reservado');
    expect(later.latitude, 38.7);
    expect(later.longitude, -9.1);
    expect(later.category, ItineraryCategory.bar);
    expect(
      day.items.firstWhere((item) => item.order == 1).googleMapsLink,
      'https://maps.example/cafe',
    );
    expect(trip.days.firstWhere((d) => d.dayNumber == 2).items, isEmpty);

    expect(
      ApiTripsDataSource(dio).getMyTrips(),
      throwsA(isA<UnsupportedError>()),
    );
  });

  test('loadTrip without an id does not call the list', () async {
    final repository = _RecordingTripsRepository();
    final cubit = TripsCubit(tripsRepository: repository);
    addTearDown(cubit.dispose);

    await cubit.loadTrip(null);
    await cubit.loadTrip('  ');

    expect(cubit.value.status, TripsStatus.loaded);
    expect(cubit.value.trips, isEmpty);
    expect(repository.getMyTripsCalls, 0);
    expect(repository.getTripByIdCalls, 0);
  });

  testWidgets('day 2 with empty items is a paywall and day 1 stays empty', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: TripItineraryView(
          trip: TripEntity(
            id: 'trip-1',
            userId: 'user-1',
            title: 'Lisboa',
            destination: 'Lisboa',
            days: [
              TripDayEntity(
                id: 'day-2',
                tripId: 'trip-1',
                dayNumber: 2,
                title: 'Dia 2',
              ),
              TripDayEntity(
                id: 'day-1',
                tripId: 'trip-1',
                dayNumber: 1,
                title: 'Dia 1',
                items: [
                  ItineraryItemEntity(
                    id: 'late',
                    tripDayId: 'day-1',
                    title: 'Jantar',
                    order: 2,
                    timeLabel: '20:00',
                    duration: 60,
                    cost: 40.0,
                    currency: 'EUR',
                    notes: 'Mesa na janela',
                    latitude: 38.71,
                    longitude: -9.14,
                  ),
                  ItineraryItemEntity(
                    id: 'early',
                    tripDayId: 'day-1',
                    title: 'Café',
                    order: 1,
                    googleMapsLink: 'https://maps.example/cafe',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text(TripItineraryView.paywallMessage), findsOneWidget);
    expect(find.text('Não foi possível carregar a viagem'), findsNothing);
    expect(find.text('20:00'), findsOneWidget);
    expect(find.text('60 min'), findsOneWidget);
    expect(find.text('EUR 40.0'), findsOneWidget);
    expect(find.text('Mesa na janela'), findsOneWidget);
    expect(
      find.text('https://www.google.com/maps/search/?api=1&query=38.71,-9.14'),
      findsOneWidget,
    );
    expect(find.text('https://maps.example/cafe'), findsOneWidget);

    final cafe = tester.getTopLeft(find.text('Café'));
    final dinner = tester.getTopLeft(find.text('Jantar'));
    final day1 = tester.getTopLeft(find.text('Dia 1'));
    final day2 = tester.getTopLeft(find.text('Dia 2'));
    expect(day1.dy, lessThan(day2.dy));
    expect(cafe.dy, lessThan(dinner.dy));
  });

  testWidgets('handoff without an id stays empty', (tester) async {
    final repository = _RecordingTripsRepository();
    await tester.pumpWidget(
      MaterialApp(home: HandoffTripsView(tripsRepository: repository)),
    );
    await tester.pump();

    expect(find.text('Minhas Viagens'), findsOneWidget);
    expect(repository.getMyTripsCalls, 0);
    expect(repository.getTripByIdCalls, 0);
  });

  testWidgets('handoff with an id opens that trip', (tester) async {
    final repository = _RecordingTripsRepository(
      trip: const TripEntity(
        id: 'trip-9',
        userId: 'user-1',
        title: 'Porto real',
        destination: 'Porto',
        days: [],
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: HandoffTripsView(tripsRepository: repository, tripId: 'trip-9'),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Porto real'), findsOneWidget);
    expect(repository.getMyTripsCalls, 0);
    expect(repository.getTripByIdCalls, 1);
    expect(find.text(TripItineraryView.paywallMessage), findsNothing);
  });
}

class _RecordingTripsRepository implements TripsRepository {
  _RecordingTripsRepository({this.trip});

  final TripEntity? trip;
  int getMyTripsCalls = 0;
  int getTripByIdCalls = 0;

  @override
  Future<List<TripEntity>> getMyTrips() async {
    getMyTripsCalls++;
    return const [];
  }

  @override
  Future<TripEntity> getTripById(String id) async {
    getTripByIdCalls++;
    return trip!;
  }

  @override
  Future<TripDayEntity> addTripDay(
    String tripId,
    int dayNumber, {
    String? title,
  }) => throw UnimplementedError();

  @override
  Future<ItineraryItemEntity> addItineraryItem(
    String dayId,
    ItineraryItemEntity item,
  ) => throw UnimplementedError();

  @override
  Future<TripEntity> createTrip({
    required String title,
    required String destination,
    DateTime? startDate,
    DateTime? endDate,
  }) => throw UnimplementedError();

  @override
  Future<void> deleteItineraryItem(String itemId) => throw UnimplementedError();

  @override
  Future<void> deleteTrip(String id) => throw UnimplementedError();

  @override
  Future<TripEntity> generateAiItinerary(
    String tripId,
    Map<String, dynamic> preferences,
  ) => throw UnimplementedError();

  @override
  Future<void> reorderItineraryItem(String itemId, int newOrder) =>
      throw UnimplementedError();

  @override
  Future<TripEntity> updateTrip(TripEntity trip) => throw UnimplementedError();

  @override
  Future<ItineraryItemEntity> updateItineraryItem(ItineraryItemEntity item) =>
      throw UnimplementedError();

  @override
  Future<AccommodationDraft?> getAccommodation(String tripId) =>
      throw UnimplementedError();

  @override
  Future<AccommodationDraft> saveAccommodation(
    String tripId,
    AccommodationDraft stay,
  ) => throw UnimplementedError();

  @override
  Future<void> deleteAccommodation(String tripId) => throw UnimplementedError();

  @override
  Future<AlternativesResult> getItemAlternatives(String itemId) =>
      throw UnimplementedError();

  @override
  Future<SwapQuota> substituteItem(String itemId, Map<String, dynamic> body) =>
      throw UnimplementedError();

  @override
  Future<MealRecommendationsResult> getMealRecommendations(
    String dayId, {
    String? period,
  }) => throw UnimplementedError();

  @override
  Future<void> pinMeal(String itemId, Map<String, dynamic> body) =>
      throw UnimplementedError();

  @override
  Future<void> updateItemDuration(String itemId, int duration) =>
      throw UnimplementedError();

  @override
  Future<VerifiedPlaceDetails?> getVerifiedDetails(String itemId) =>
      throw UnimplementedError();
}
