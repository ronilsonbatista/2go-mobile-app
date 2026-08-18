import 'package:app_roteiros_api/app_roteiros_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_places/places.dart';

class FakePlacesApiClient implements PlacesApiClient {
  List<PlaceSearchResultDto> searchResults = [];
  bool shouldThrow = false;

  @override
  Future<List<PlaceSearchResultDto>> searchPlaces(String query) async {
    if (shouldThrow) throw Exception('Places API Error');
    return searchResults;
  }

  @override
  Future<PlaceSearchResultDto?> getPlaceDetails(String providerPlaceId) async {
    if (shouldThrow) throw Exception('Places API Error');
    return searchResults.firstWhere(
      (e) => e.providerPlaceId == providerPlaceId,
    );
  }
}

void main() {
  late FakePlacesApiClient apiClient;
  late PlacesRepositoryImpl repository;
  late SearchPlacesUseCase searchUseCase;

  setUp(() {
    apiClient = FakePlacesApiClient();
    repository = PlacesRepositoryImpl(apiClient: apiClient);
    searchUseCase = SearchPlacesUseCase(repository: repository);
  });

  group('SearchPlacesUseCase & PlacesRepository Tests', () {
    test(
      'searchPlaces returns empty list for empty query without calling API',
      () async {
        final result = await searchUseCase('');
        expect(result.isSuccess, isTrue);
        expect(result.getOrNull(), isEmpty);
      },
    );

    test('searchPlaces returns mapped search results on API success', () async {
      apiClient.searchResults = [
        const PlaceSearchResultDto(
          provider: 'GOOGLE',
          providerPlaceId: 'place_paris_001',
          name: 'Paris',
          formattedAddress: 'Paris, France',
        ),
      ];

      final result = await searchUseCase('Paris');
      expect(result.isSuccess, isTrue);
      final list = result.getOrNull()!;
      expect(list.length, 1);
      expect(list.first.providerPlaceId, 'place_paris_001');
      expect(list.first.city, 'Paris');
      expect(list.first.country, 'France');
    });

    test('searchPlaces handles API failure cleanly with AppFailure', () async {
      apiClient.shouldThrow = true;
      final result = await searchUseCase('ErrorQuery');
      expect(result.isFailure, isTrue);
    });
  });
}
