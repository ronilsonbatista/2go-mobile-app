import 'package:app_roteiros_api/app_roteiros_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_design_system/design_system.dart';
import 'package:twogo_places/places.dart';
import 'package:twogo_planning/twogo_planning.dart';

class _FakePlacesApiClient implements PlacesApiClient {
  @override
  Future<List<PlaceSearchResultDto>> searchPlaces(String query) async {
    return [
      const PlaceSearchResultDto(
        provider: 'GOOGLE',
        providerPlaceId: 'ChIJRoma',
        name: 'Roma',
        formattedAddress: 'Itália',
      ),
    ];
  }

  @override
  Future<List<PlaceSearchResultDto>> searchHotelsAutocomplete(
    String query, {
    double? latitude,
    double? longitude,
    int? radiusMeters,
  }) async =>
      const [];

  @override
  Future<List<PlaceSearchResultDto>> searchHotels(
    String query, {
    double? latitude,
    double? longitude,
  }) async =>
      const [];

  @override
  Future<PlaceSearchResultDto?> getPlaceDetails(String providerPlaceId) async =>
      null;
}

void main() {
  testWidgets(
    'destination search opens as fullscreen route, not bottom sheet',
    (tester) async {
      final search = SearchPlacesUseCase(
        repository: PlacesRepositoryImpl(apiClient: _FakePlacesApiClient()),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    DestinationSearchSheet.show(
                      context,
                      searchPlacesUseCase: search,
                    );
                  },
                  child: const Text('Abrir busca'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Abrir busca'));
      await tester.pumpAndSettle();

      expect(find.text('Para onde você vai?'), findsOneWidget);
      expect(find.byType(DestinationSearchSheet), findsOneWidget);
      // Half-sheet chrome must not appear.
      expect(find.byType(TwoGoBottomSheet), findsNothing);
    },
  );
}
