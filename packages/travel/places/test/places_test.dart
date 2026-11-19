import 'package:app_roteiros_api/app_roteiros_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_places/places.dart';

class FakePlacesApiClient implements PlacesApiClient {
  List<PlaceSearchResultDto> searchResults = [];
  List<PlaceSearchResultDto> hotelResults = [];
  bool shouldThrow = false;
  bool hotelAutocompleteEmpty = false;

  @override
  Future<List<PlaceSearchResultDto>> searchPlaces(String query) async {
    if (shouldThrow) throw Exception('Places API Error');
    return searchResults;
  }

  @override
  Future<List<PlaceSearchResultDto>> searchHotelsAutocomplete(
    String query, {
    double? latitude,
    double? longitude,
    int? radiusMeters,
  }) async {
    if (shouldThrow) throw Exception('Places API Error');
    if (hotelAutocompleteEmpty) return const [];
    return hotelResults.isNotEmpty ? hotelResults : searchResults;
  }

  @override
  Future<List<PlaceSearchResultDto>> searchHotels(
    String query, {
    double? latitude,
    double? longitude,
  }) async {
    if (shouldThrow) throw Exception('Places API Error');
    return hotelResults.isNotEmpty ? hotelResults : searchResults;
  }

  @override
  Future<PlaceSearchResultDto?> getPlaceDetails(String providerPlaceId) async {
    if (shouldThrow) throw Exception('Places API Error');
    final pool = [...hotelResults, ...searchResults];
    return pool.firstWhere((e) => e.providerPlaceId == providerPlaceId);
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
      expect(list.first.iconUrl, isNull);
    });

    test('maps iconUrl from DTO onto domain PlaceSearchResult', () async {
      apiClient.searchResults = [
        const PlaceSearchResultDto(
          provider: 'GOOGLE',
          providerPlaceId: 'places/ChIJRoma',
          name: 'Roma',
          formattedAddress: 'Roma, Itália',
          iconUrl: 'https://cdn.example/static/place-icons/city.svg',
        ),
      ];

      final result = await searchUseCase('Roma');
      expect(result.isSuccess, isTrue);
      expect(
        result.getOrNull()!.single.iconUrl,
        'https://cdn.example/static/place-icons/city.svg',
      );
    });

    test('falls back to imageUrl when iconUrl is absent', () async {
      apiClient.searchResults = [
        const PlaceSearchResultDto(
          provider: 'GOOGLE',
          providerPlaceId: 'places/ChIJParis',
          name: 'Paris',
          imageUrl: 'https://cdn.example/paris.jpg',
        ),
      ];

      final result = await searchUseCase('Paris');
      expect(result.isSuccess, isTrue);
      expect(
        result.getOrNull()!.single.iconUrl,
        'https://cdn.example/paris.jpg',
      );
    });

    test('prefers iconUrl over imageUrl when both are present', () async {
      apiClient.searchResults = [
        const PlaceSearchResultDto(
          provider: 'GOOGLE',
          providerPlaceId: 'places/ChIJBoth',
          name: 'Lisboa',
          iconUrl: 'https://cdn.example/icon.svg',
          imageUrl: 'https://cdn.example/image.jpg',
        ),
      ];

      final result = await searchUseCase('Lisboa');
      expect(result.getOrNull()!.single.iconUrl, 'https://cdn.example/icon.svg');
    });

    test('searchPlaces handles API failure cleanly with AppFailure', () async {
      apiClient.shouldThrow = true;
      final result = await searchUseCase('ErrorQuery');
      expect(result.isFailure, isTrue);
    });
  });

  group('PlaceSearchResultDto', () {
    test('fromJson reads iconUrl and imageUrl', () {
      final dto = PlaceSearchResultDto.fromJson({
        'providerPlaceId': 'places/ChIJ1',
        'name': 'Roma',
        'formattedAddress': 'Roma, Itália',
        'iconUrl': 'https://cdn.example/icon.svg',
        'imageUrl': 'https://cdn.example/img.jpg',
      });

      expect(dto.iconUrl, 'https://cdn.example/icon.svg');
      expect(dto.imageUrl, 'https://cdn.example/img.jpg');
      expect(dto.resolvedIconUrl, 'https://cdn.example/icon.svg');
    });

    test('fromJson treats blank iconUrl as null and uses imageUrl', () {
      final dto = PlaceSearchResultDto.fromJson({
        'providerPlaceId': 'places/ChIJ2',
        'name': 'Paris',
        'iconUrl': '   ',
        'imageUrl': 'https://cdn.example/paris.jpg',
      });

      expect(dto.iconUrl, isNull);
      expect(dto.resolvedIconUrl, 'https://cdn.example/paris.jpg');
    });
  });

  group('SearchHotelsUseCase', () {
    late SearchHotelsUseCase searchHotels;

    setUp(() {
      searchHotels = SearchHotelsUseCase(repository: repository);
    });

    test('returns empty without calling API when query shorter than 2', () async {
      final result = await searchHotels('H');
      expect(result.isSuccess, isTrue);
      expect(result.getOrNull(), isEmpty);
    });

    test('prefers autocomplete results', () async {
      apiClient.hotelResults = [
        const PlaceSearchResultDto(
          provider: 'GOOGLE',
          providerPlaceId: 'hotel-1',
          name: 'Hotel Diana Roof Garden',
          formattedAddress: 'Roma, Itália',
        ),
      ];
      final result = await searchHotels('Ho');
      expect(result.getOrNull()!.single.name, 'Hotel Diana Roof Garden');
    });

    test('falls back to hotels search when autocomplete is empty', () async {
      apiClient.hotelAutocompleteEmpty = true;
      apiClient.hotelResults = [
        const PlaceSearchResultDto(
          provider: 'GOOGLE',
          providerPlaceId: 'hotel-2',
          name: 'The Hoxton Rome',
          formattedAddress: 'Roma, Itália',
        ),
      ];
      // Autocomplete empty path uses hotelResults for searchHotels too —
      // force searchPlaces-style by clearing after autocomplete.
      final result = await searchHotels('Hoxton');
      expect(result.isSuccess, isTrue);
      expect(result.getOrNull()!.single.name, 'The Hoxton Rome');
    });
  });

  group('PlacesApiClient autocomplete', () {
    test('GET /places/autocomplete?q= reads data.items envelope', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://core.test'));
      String? path;
      Map<String, dynamic>? query;

      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            path = options.path;
            query = Map<String, dynamic>.from(options.queryParameters);
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'success': true,
                  'data': {
                    'items': [
                      {
                        'providerPlaceId': 'places/ChIJRoma',
                        'name': 'Roma',
                        'formattedAddress': 'Roma, Itália',
                        'iconUrl':
                            'https://cdn.example/static/place-icons/city.svg',
                      },
                    ],
                  },
                  'timestamp': '2026-11-18T00:00:00.000Z',
                },
              ),
            );
          },
        ),
      );

      final client = PlacesApiClient(dio);
      final results = await client.searchPlaces('Roma');

      expect(path, '/places/autocomplete');
      expect(query?['q'], 'Roma');
      expect(query?.containsKey('query'), isFalse);
      expect(results, hasLength(1));
      expect(results.single.providerPlaceId, 'places/ChIJRoma');
      expect(
        results.single.iconUrl,
        'https://cdn.example/static/place-icons/city.svg',
      );
    });

    test('reads unwrapped { items } after ApiEnvelopeInterceptor', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://core.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'items': [
                    {
                      'providerPlaceId': 'places/ChIJParis',
                      'name': 'Paris',
                      'imageUrl': 'https://cdn.example/paris.jpg',
                    },
                  ],
                },
              ),
            );
          },
        ),
      );

      final client = PlacesApiClient(dio);
      final results = await client.searchPlaces('Paris');

      expect(results.single.resolvedIconUrl, 'https://cdn.example/paris.jpg');
    });

    test('GET /places/hotels/autocomplete?q= with lat/lng bias', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://core.test'));
      String? path;
      Map<String, dynamic>? query;

      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            path = options.path;
            query = Map<String, dynamic>.from(options.queryParameters);
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'items': [
                    {
                      'providerPlaceId': 'ChIJHotel',
                      'name': 'Hotel Diana Roof Garden',
                      'subtitle': 'Roma, Itália',
                    },
                  ],
                },
              ),
            );
          },
        ),
      );

      final client = PlacesApiClient(dio);
      final results = await client.searchHotelsAutocomplete(
        'Ho',
        latitude: 41.9,
        longitude: 12.5,
        radiusMeters: 8000,
      );

      expect(path, '/places/hotels/autocomplete');
      expect(query?['q'], 'Ho');
      expect(query?['lat'], 41.9);
      expect(query?['lng'], 12.5);
      expect(query?['radiusMeters'], 8000);
      expect(results.single.name, 'Hotel Diana Roof Garden');
      expect(results.single.formattedAddress, 'Roma, Itália');
    });

    test('GET /places/hotels/search?q= fallback path', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://core.test'));
      String? path;

      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            path = options.path;
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'items': [
                    {
                      'providerPlaceId': 'ChIJHoxton',
                      'name': 'The Hoxton Rome',
                    },
                  ],
                },
              ),
            );
          },
        ),
      );

      final client = PlacesApiClient(dio);
      final results = await client.searchHotels('Hoxton');
      expect(path, '/places/hotels/search');
      expect(results.single.name, 'The Hoxton Rome');
    });
  });
}
