import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_trips/trips.dart';

void main() {
  test('phase 3 bodies keep only fields that arrived', () {
    final alternative = ItemAlternative.fromJson({
      'title': 'Galeria',
      'location': 'Rua A',
      'cost': 0,
      'currency': 'EUR',
      'ticketStatus': 'FREE',
      'rating': 4.5,
      'source': 'PLACES',
      'googleMapsUri': 'https://maps.example/galeria',
    });
    expect(alternative.toSubstituteBody(), {
      'title': 'Galeria',
      'location': 'Rua A',
      'cost': 0,
      'currency': 'EUR',
      'ticketStatus': 'FREE',
    });
    expect(
      ItemAlternative.fromJson({
        'description': 'sem título',
      }).toSubstituteBody(),
      isNull,
    );

    final meal = MealRecommendation.fromJson({
      'name': 'Trattoria',
      'address': 'Rua A',
      'priceLevel': 2,
      'priceRange': '€€',
      'recommendedDish': 'Carbonara',
      'providerPlaceId': 'place-1',
      'latitude': 1.2,
      'longitude': 3.4,
      'googleMapsUri': 'https://maps.example/meal',
    });
    expect(meal.toPinBody(), {
      'title': 'Trattoria',
      'location': 'Rua A',
      'notes': 'Carbonara',
      'providerPlaceId': 'place-1',
      'latitude': 1.2,
      'longitude': 3.4,
      'googleMapsLink': 'https://maps.example/meal',
    });
    expect(meal.toPinBody()!.containsKey('cost'), isFalse);
    expect(meal.toPinBody()!.containsKey('priceLevel'), isFalse);

    final stay = AccommodationDraft.fromJson({
      'name': 'Hotel',
      'address': 'Rua Garrett',
      'latitude': 38.71,
      'checkInDateTime': '2026-10-01T15:00:00.000Z',
    });
    expect(stay.toJson(), {
      'name': 'Hotel',
      'address': 'Rua Garrett',
      'latitude': 38.71,
      'checkInDateTime': '2026-10-01T15:00:00.000Z',
    });

    final details = VerifiedPlaceDetails.fromJson({
      'name': 'Castelo',
      'rating': null,
      'types': ['museum', ''],
      'extra': 'não mostrar',
    });
    expect(details.name, 'Castelo');
    expect(details.rating, isNull);
    expect(details.types, ['museum']);
    expect(details.websiteUri, isNull);

    const exhausted = SwapQuota(
      allowedSwapsCount: 4,
      usedSwapsCount: 4,
      remainingSwaps: 0,
    );
    expect(exhausted.label, 'Trocas: 4 de 4');
    expect(exhausted.canSubstitute, isFalse);
    expect(const SwapQuota().canSubstitute, isFalse);
    expect(const SwapQuota().label, isNull);
  });

  test('api client calls the canonical phase 3 paths', () async {
    final calls = <_Call>[];
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          calls.add(
            _Call(
              options.method,
              options.path,
              options.data,
              Map<String, dynamic>.from(options.queryParameters),
            ),
          );
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              data: _payload(options.method, options.path),
            ),
          );
        },
      ),
    );
    final api = ApiTripsDataSource(dio);

    expect(await api.getAccommodation('trip 1'), isNull);
    final saved = await api.saveAccommodation(
      'trip 1',
      const AccommodationDraft(name: 'Hotel', latitude: 38.71),
    );
    expect(saved.name, 'Hotel');
    expect(saved.latitude, 38.71);
    await api.deleteAccommodation('trip 1');

    final alternatives = await api.getItemAlternatives('item 1');
    expect(alternatives.quota.label, 'Trocas: 1 de 4');
    expect(alternatives.items.single.title, 'Galeria');
    final quota = await api.substituteItem('item 1', {'title': 'Galeria'});
    expect(quota.remainingSwaps, 2);

    final meals = await api.getMealRecommendations('day 1');
    expect(meals.period, 'Geral');
    expect(meals.recommendations.single.priceLevel, '2');
    await api.getMealRecommendations('day 1', period: 'TARDE');
    await api.pinMeal('item 1', {'title': 'Trattoria'});
    await api.updateItemDuration('item 1', 90);

    expect(await api.getVerifiedDetails('item 1'), isNull);
    final verified = await api.getVerifiedDetails('item-details');
    expect(verified?.name, 'Castelo');
    expect(verified?.rating, 4.6);
    expect(verified?.websiteUri, isNull);

    expect(calls.map((call) => '${call.method} ${call.path}'), [
      'GET /trips/trip%201/accommodation',
      'POST /trips/trip%201/accommodation',
      'DELETE /trips/trip%201/accommodation',
      'GET /itinerary-items/item%201/alternatives',
      'POST /itinerary-items/item%201/substitute',
      'GET /trip-days/day%201/meal-recommendations',
      'GET /trip-days/day%201/meal-recommendations',
      'PATCH /itinerary-items/item%201/pin-meal',
      'PATCH /itinerary-items/item%201',
      'GET /itinerary-items/item%201',
      'GET /itinerary-items/item-details',
    ]);
    expect(calls[1].data, {'name': 'Hotel', 'latitude': 38.71});
    expect(calls[4].data, {'title': 'Galeria'});
    expect(calls[5].query, isEmpty);
    expect(calls[6].query, {'period': 'TARDE'});
    expect(calls[7].data, {'title': 'Trattoria'});
    expect(calls[8].data, {'duration': 90});

    expect(api.getMyTrips(), throwsA(isA<UnsupportedError>()));
    expect(
      api.updateItineraryItem('item 1', {'title': 'não'}),
      throwsA(isA<UnsupportedError>()),
    );
    expect(
      MockTripsDataSource().getItemAlternatives('item'),
      throwsA(isA<UnsupportedError>()),
    );
    expect(
      MockTripsDataSource().getMealRecommendations('day'),
      throwsA(isA<UnsupportedError>()),
    );
  });

  testWidgets('paid controls stay off a display-only itinerary', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: TripItineraryView(trip: _trip())),
    );

    expect(find.text('Substituir'), findsNothing);
    expect(find.text('Duração'), findsNothing);
    expect(find.text('Detalhes'), findsNothing);
    expect(find.text('Sugestões de refeição'), findsNothing);
    expect(find.text('Cadastrar hospedagem'), findsNothing);
    expect(find.text('Editar hospedagem'), findsNothing);
  });

  testWidgets('paywalled day does not offer phase 3 actions', (tester) async {
    final repository = _ScriptedTripsRepository([
      _trip(
        days: [
          TripDayEntity(
            id: 'day-1',
            tripId: 'trip-1',
            dayNumber: 1,
            items: [_item(id: 'cafe', title: 'Café')],
          ),
          const TripDayEntity(
            id: 'day-2',
            tripId: 'trip-1',
            dayNumber: 2,
            title: 'Dia 2',
          ),
        ],
      ),
    ]);
    await _pumpHandoff(tester, repository);

    expect(find.text(TripItineraryView.paywallMessage), findsOneWidget);
    expect(find.text('Substituir'), findsOneWidget);
    expect(find.text('Sugestões de refeição'), findsOneWidget);
  });

  testWidgets('accommodation form resends loaded fields and reloads the trip', (
    tester,
  ) async {
    final repository = _ScriptedTripsRepository([
      _trip(),
      _trip(
        accommodation: const TripAccommodation(
          id: 'stay-1',
          name: 'Hotel Novo',
          address: 'Rua Garrett',
          latitude: 38.71,
        ),
      ),
    ]);
    repository.accommodation = const AccommodationDraft(
      name: 'Hotel do Chiado',
      address: 'Rua Garrett',
      latitude: 38.71,
      checkInDateTime: '2026-10-01T15:00:00.000Z',
    );
    await _pumpHandoff(tester, repository);

    await tester.tap(find.text('Cadastrar hospedagem'));
    await _settleSheet(tester);
    expect(find.text('Carregando'), findsNothing);
    await tester.enterText(
      find.byKey(const Key('accommodation-name')),
      'Hotel Novo',
    );
    await tester.tap(find.text('Salvar hospedagem'));
    await _settleSheet(tester);

    expect(repository.saved.single.toJson(), {
      'name': 'Hotel Novo',
      'address': 'Rua Garrett',
      'latitude': 38.71,
      'checkInDateTime': '2026-10-01T15:00:00.000Z',
    });
    expect(find.text('Hotel Novo'), findsOneWidget);
    expect(repository.tripCalls, 2);
  });

  testWidgets('exhausted swap quota hides substitute', (tester) async {
    final repository = _ScriptedTripsRepository([_trip()]);
    repository.alternatives = AlternativesResult(
      quota: const SwapQuota(
        allowedSwapsCount: 4,
        usedSwapsCount: 4,
        remainingSwaps: 0,
      ),
      items: [
        ItemAlternative.fromJson({
          'title': 'Galeria',
          'description': 'Coleção',
        }),
      ],
    );
    await _pumpHandoff(tester, repository);
    await tester.tap(find.text('Substituir'));
    await _settleSheet(tester);

    expect(find.text('Trocas: 4 de 4'), findsWidgets);
    expect(find.text('Cota de trocas esgotada'), findsOneWidget);
    expect(find.text('Galeria'), findsOneWidget);
    expect(find.text('Usar esta'), findsNothing);
    expect(repository.substitutes, isEmpty);
  });

  testWidgets('substitute sends the alternative and reloads time labels', (
    tester,
  ) async {
    final repository = _ScriptedTripsRepository([
      _trip(),
      _trip(
        items: [_item(id: 'cafe', title: 'Galeria', timeLabel: '11:00')],
      ),
    ]);
    repository.alternatives = AlternativesResult(
      quota: const SwapQuota(
        allowedSwapsCount: 4,
        usedSwapsCount: 1,
        remainingSwaps: 3,
      ),
      items: [
        ItemAlternative.fromJson({
          'title': 'Galeria',
          'location': 'Rua A',
          'providerPlaceId': 'place-9',
          'latitude': 38.7,
          'rating': 4.8,
          'source': 'PLACES',
        }),
      ],
    );
    await _pumpHandoff(tester, repository);
    await tester.tap(find.text('Substituir'));
    await _settleSheet(tester);
    expect(find.text('Trocas: 1 de 4'), findsWidgets);
    expect(find.text('Avaliação: 4.8'), findsOneWidget);
    await tester.tap(find.text('Usar esta'));
    await _settleSheet(tester);

    expect(repository.substitutes.single, {
      'title': 'Galeria',
      'location': 'Rua A',
      'providerPlaceId': 'place-9',
      'latitude': 38.7,
    });
    expect(find.text('11:00'), findsOneWidget);
    expect(find.text('09:00'), findsNothing);
  });

  testWidgets('duration patch reloads the day time labels from the trip', (
    tester,
  ) async {
    final repository = _ScriptedTripsRepository([
      _trip(
        items: [
          _item(id: 'cafe', title: 'Café', timeLabel: '09:00', duration: 60),
          _item(id: 'castle', title: 'Castelo', timeLabel: '10:00', order: 2),
        ],
      ),
      _trip(
        items: [
          _item(id: 'cafe', title: 'Café', timeLabel: '09:00', duration: 120),
          _item(id: 'castle', title: 'Castelo', timeLabel: '11:30', order: 2),
        ],
      ),
    ]);
    await _pumpHandoff(tester, repository);
    expect(find.text('10:00'), findsOneWidget);

    await tester.tap(find.text('Duração').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.enterText(find.byKey(const Key('item-duration')), '120');
    await tester.tap(find.text('Salvar duração'));
    await _settleSheet(tester);

    expect(repository.durations.single.id, 'cafe');
    expect(repository.durations.single.duration, 120);
    expect(find.text('11:30'), findsOneWidget);
    expect(find.text('10:00'), findsNothing);
  });

  testWidgets('verified details show only returned fields', (tester) async {
    final repository = _ScriptedTripsRepository([_trip()]);
    await _pumpHandoff(tester, repository);
    await tester.tap(find.text('Detalhes'));
    await _settleSheet(tester);
    expect(find.text('Sem detalhes verificados'), findsOneWidget);
    expect(find.textContaining('Avaliação'), findsNothing);

    Navigator.of(tester.element(find.text('Sem detalhes verificados'))).pop();
    await _settleSheet(tester);

    repository.details = const VerifiedPlaceDetails(
      name: 'Castelo de São Jorge',
      rating: 4.6,
      priceLevel: '2',
      googleMapsUri: 'https://maps.example/castelo',
    );
    await tester.tap(find.text('Detalhes'));
    await _settleSheet(tester);

    expect(find.text('Nome: Castelo de São Jorge'), findsOneWidget);
    expect(find.text('Avaliação: 4.6'), findsOneWidget);
    expect(find.text('Nível de preço: 2'), findsOneWidget);
    expect(find.text('https://maps.example/castelo'), findsOneWidget);
    expect(find.textContaining('Telefone'), findsNothing);
    expect(find.textContaining('Site'), findsNothing);
  });

  testWidgets('pin meal sends no invented cost and can filter by item period', (
    tester,
  ) async {
    final repository = _ScriptedTripsRepository([
      _trip(
        items: [_item(id: 'lunch', title: 'Almoço', period: 'TARDE')],
      ),
      _trip(
        items: [_item(id: 'lunch', title: 'Trattoria', timeLabel: '13:00')],
      ),
    ]);
    repository.meals = MealRecommendationsResult(
      destination: 'Lisboa',
      period: 'Geral',
      recommendations: [
        MealRecommendation.fromJson({
          'name': 'Trattoria',
          'address': 'Rua A',
          'priceLevel': 2,
          'recommendedDish': 'Carbonara',
          'providerPlaceId': 'place-1',
          'latitude': 1.2,
          'longitude': 3.4,
          'googleMapsUri': 'https://maps.example/meal',
        }),
      ],
    );
    await _pumpHandoff(tester, repository);
    await tester.tap(find.text('Sugestões de refeição'));
    await _settleSheet(tester);

    expect(repository.mealPeriods, [null]);
    expect(find.text('Trattoria'), findsOneWidget);
    expect(find.text('Nível de preço: 2'), findsOneWidget);
    expect(find.text('Carbonara'), findsOneWidget);
    expect(find.textContaining('€'), findsNothing);

    await tester.tap(find.text('TARDE'));
    await tester.pump();
    await tester.pump();
    expect(repository.mealPeriods, [null, 'TARDE']);

    await tester.tap(find.text('Fixar'));
    await _settleSheet(tester);

    expect(repository.pins.single.id, 'lunch');
    expect(repository.pins.single.body, {
      'title': 'Trattoria',
      'location': 'Rua A',
      'notes': 'Carbonara',
      'providerPlaceId': 'place-1',
      'latitude': 1.2,
      'longitude': 3.4,
      'googleMapsLink': 'https://maps.example/meal',
    });
    expect(find.text('13:00'), findsOneWidget);
  });

  testWidgets('substitute surfaces the server quota error', (tester) async {
    final repository = _ScriptedTripsRepository([_trip()]);
    repository.alternatives = AlternativesResult(
      quota: const SwapQuota(
        allowedSwapsCount: 4,
        usedSwapsCount: 1,
        remainingSwaps: 3,
      ),
      items: [
        ItemAlternative.fromJson({'title': 'Galeria'}),
      ],
    );
    repository.substituteError = DioException(
      requestOptions: RequestOptions(path: '/itinerary-items/cafe/substitute'),
      response: Response<Map<String, dynamic>>(
        requestOptions: RequestOptions(
          path: '/itinerary-items/cafe/substitute',
        ),
        statusCode: 400,
        data: {
          'message':
              'Cota de trocas esgotada (4/4). Não é possível realizar mais substituições nesta viagem.',
        },
      ),
    );
    await _pumpHandoff(tester, repository);
    await tester.tap(find.text('Substituir'));
    await _settleSheet(tester);
    await tester.tap(find.text('Usar esta'));
    await tester.pump();

    expect(
      find.text(
        'Cota de trocas esgotada (4/4). Não é possível realizar mais substituições nesta viagem.',
      ),
      findsOneWidget,
    );
    expect(find.text('Café'), findsOneWidget);
  });
}

Future<void> _pumpHandoff(
  WidgetTester tester,
  TripsRepository repository,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: HandoffTripsView(tripsRepository: repository, tripId: 'trip-1'),
    ),
  );
  await tester.pump();
  await tester.pump();
}

Future<void> _settleSheet(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

TripEntity _trip({
  TripAccommodation? accommodation,
  List<TripDayEntity>? days,
  List<ItineraryItemEntity>? items,
}) {
  return TripEntity(
    id: 'trip-1',
    userId: 'user-1',
    title: 'Lisboa',
    destination: 'Lisboa',
    accommodation: accommodation,
    days:
        days ??
        [
          TripDayEntity(
            id: 'day-1',
            tripId: 'trip-1',
            dayNumber: 1,
            items: items ?? [_item()],
          ),
        ],
  );
}

ItineraryItemEntity _item({
  String id = 'cafe',
  String title = 'Café',
  String? timeLabel = '09:00',
  int? duration,
  int order = 1,
  String? period,
}) {
  return ItineraryItemEntity(
    id: id,
    tripDayId: 'day-1',
    title: title,
    order: order,
    timeLabel: timeLabel,
    duration: duration,
    period: period,
  );
}

class _Call {
  _Call(this.method, this.path, this.data, this.query);

  final String method;
  final String path;
  final Object? data;
  final Map<String, dynamic> query;
}

dynamic _payload(String method, String path) {
  if (path.endsWith('/accommodation') && method == 'GET') return null;
  if (path.endsWith('/accommodation') && method == 'POST') {
    return {'name': 'Hotel', 'latitude': 38.71};
  }
  if (path.endsWith('/accommodation')) {
    return {'message': 'Hospedagem removida com sucesso'};
  }
  if (path.endsWith('/alternatives')) {
    return {
      'items': [
        {'title': 'Galeria'},
      ],
      'quota': {
        'allowedSwapsCount': 4,
        'usedSwapsCount': 1,
        'remainingSwaps': 3,
      },
    };
  }
  if (path.endsWith('/substitute')) {
    return {
      'item': {'id': 'item 1', 'title': 'Galeria'},
      'quota': {
        'allowedSwapsCount': 4,
        'usedSwapsCount': 2,
        'remainingSwaps': 2,
      },
    };
  }
  if (path.endsWith('/meal-recommendations')) {
    return {
      'destination': 'Lisboa',
      'period': 'Geral',
      'recommendations': [
        {'name': 'Trattoria', 'priceLevel': 2},
      ],
    };
  }
  if (path.endsWith('/pin-meal')) {
    return {'message': 'Refeição fixada com sucesso'};
  }
  if (path == '/itinerary-items/item-details') {
    return {
      'id': 'item-details',
      'title': 'Castelo',
      'verifiedDetails': {
        'name': 'Castelo',
        'rating': 4.6,
        'websiteUri': null,
        'notAField': 'oculto',
      },
    };
  }
  if (path == '/itinerary-items/item%201' && method == 'GET') {
    return {'id': 'item 1', 'title': 'Café', 'verifiedDetails': null};
  }
  return {'id': 'item 1', 'title': 'Café', 'duration': 90};
}

class _ScriptedTripsRepository implements TripsRepository {
  _ScriptedTripsRepository(this.trips);

  final List<TripEntity> trips;
  var tripCalls = 0;
  AccommodationDraft? accommodation;
  final List<AccommodationDraft> saved = [];
  AlternativesResult alternatives = const AlternativesResult(
    items: [],
    quota: SwapQuota(),
  );
  final List<Map<String, dynamic>> substitutes = [];
  Object? substituteError;
  MealRecommendationsResult meals = const MealRecommendationsResult();
  final List<String?> mealPeriods = [];
  final List<({String id, Map<String, dynamic> body})> pins = [];
  final List<({String id, int duration})> durations = [];
  VerifiedPlaceDetails? details;

  @override
  Future<TripEntity> getTripById(String id) async {
    final index = tripCalls >= trips.length ? trips.length - 1 : tripCalls;
    tripCalls++;
    return trips[index];
  }

  @override
  Future<List<TripEntity>> getMyTrips() async => const [];

  @override
  Future<AccommodationDraft?> getAccommodation(String tripId) async =>
      accommodation;

  @override
  Future<AccommodationDraft> saveAccommodation(
    String tripId,
    AccommodationDraft stay,
  ) async {
    saved.add(stay);
    return stay;
  }

  @override
  Future<void> deleteAccommodation(String tripId) async {}

  @override
  Future<AlternativesResult> getItemAlternatives(String itemId) async =>
      alternatives;

  @override
  Future<SwapQuota> substituteItem(
    String itemId,
    Map<String, dynamic> body,
  ) async {
    substitutes.add(body);
    final error = substituteError;
    if (error != null) throw error;
    return alternatives.quota;
  }

  @override
  Future<MealRecommendationsResult> getMealRecommendations(
    String dayId, {
    String? period,
  }) async {
    mealPeriods.add(period);
    return meals;
  }

  @override
  Future<void> pinMeal(String itemId, Map<String, dynamic> body) async {
    pins.add((id: itemId, body: body));
  }

  @override
  Future<void> updateItemDuration(String itemId, int duration) async {
    durations.add((id: itemId, duration: duration));
  }

  @override
  Future<VerifiedPlaceDetails?> getVerifiedDetails(String itemId) async =>
      details;

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
}
