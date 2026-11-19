import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_core/twogo_core.dart';
import 'package:twogo_design_system/design_system.dart';
import 'package:twogo_places/places.dart';
import 'package:twogo_trips/trips.dart';

class _FakeSearchHotels extends SearchHotelsUseCase {
  _FakeSearchHotels() : super(repository: _UnusedRepo());

  @override
  Future<Result<List<PlaceSearchResult>>> call(
    String query, {
    double? latitude,
    double? longitude,
    int? radiusMeters,
  }) async {
    if (query.trim().length < 2) return Result.success(const []);
    return Result.success(const [
      PlaceSearchResult(
        providerPlaceId: 'p1',
        name: 'Hotel Diana Roof Garden',
        formattedAddress: 'Roma, Itália',
        latitude: 41.9,
        longitude: 12.5,
      ),
    ]);
  }
}

class _FakeDetails extends GetPlaceDetailsUseCase {
  _FakeDetails() : super(repository: _UnusedRepo());

  @override
  Future<Result<PlaceSearchResult?>> call(String providerPlaceId) async {
    return Result.success(
      PlaceSearchResult(
        providerPlaceId: providerPlaceId,
        name: 'Hotel Diana Roof Garden',
        formattedAddress: 'Piazza del Viminale, 14, 00184 Roma, Itália.',
        latitude: 41.9,
        longitude: 12.5,
      ),
    );
  }
}

class _UnusedRepo implements PlacesRepository {
  @override
  Future<Result<PlaceSearchResult?>> getPlaceDetails(String id) async =>
      Result.success(null);

  @override
  Future<Result<List<PlaceSearchResult>>> searchHotels(
    String query, {
    double? latitude,
    double? longitude,
  }) async =>
      Result.success(const []);

  @override
  Future<Result<List<PlaceSearchResult>>> searchHotelsAutocomplete(
    String query, {
    double? latitude,
    double? longitude,
    int? radiusMeters,
  }) async =>
      Result.success(const []);

  @override
  Future<Result<List<PlaceSearchResult>>> searchPlaces(String query) async =>
      Result.success(const []);
}

void main() {
  testWidgets('search page shows manual CTA and hotel results', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: TwoGoTheme.light,
        home: AddAccommodationSearchPage(
          controls: TripControls(
            repository: _NoopTrips(),
            reloadTrip: () async {},
          ),
          tripId: 't1',
          searchHotels: _FakeSearchHotels(),
          getPlaceDetails: _FakeDetails(),
        ),
      ),
    );

    expect(find.text('Adicionar hospedagem'), findsOneWidget);
    expect(find.text('Adicionar endereço manualmente'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('hotel-search-field')), 'Ho');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    expect(find.text('Hotel Diana Roof Garden'), findsOneWidget);
  });

  testWidgets('manual address sheet returns candidate', (tester) async {
    AccommodationCandidate? result;
    await tester.pumpWidget(
      MaterialApp(
        theme: TwoGoTheme.light,
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: TextButton(
                onPressed: () async {
                  result = await showManualAddressSheet(context);
                },
                child: const Text('open'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('manual-street')), 'Via Roma');
    await tester.enterText(find.byKey(const Key('manual-number')), '10');
    await tester.enterText(find.byKey(const Key('manual-neighborhood')), 'Centro');
    await tester.enterText(find.byKey(const Key('manual-zip')), '00184');
    await tester.tap(find.text('Salvar endereço'));
    await tester.pumpAndSettle();

    expect(result?.name, 'Via Roma');
    expect(result?.zipCode, '00184');
    expect(result?.neighborhood, 'Centro');
    expect(result?.address, contains('Via Roma, 10'));
  });
}

class _NoopTrips implements TripsRepository {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
