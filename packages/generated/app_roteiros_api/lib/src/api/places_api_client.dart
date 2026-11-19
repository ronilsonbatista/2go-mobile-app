import 'package:dio/dio.dart';

class PlaceSearchResultDto {
  final String provider;
  final String providerPlaceId;
  final String name;
  final String? formattedAddress;
  final double? latitude;
  final double? longitude;
  final double? rating;
  final int? userRatingsTotal;
  final String? googleMapsUri;
  final String? websiteUri;
  final List<String> types;

  /// Predefined locality thumb from Core (`iconUrl` preferred; else `imageUrl`).
  final String? iconUrl;

  /// Alternate image field some Core payloads use instead of [iconUrl].
  final String? imageUrl;

  const PlaceSearchResultDto({
    required this.provider,
    required this.providerPlaceId,
    required this.name,
    this.formattedAddress,
    this.latitude,
    this.longitude,
    this.rating,
    this.userRatingsTotal,
    this.googleMapsUri,
    this.websiteUri,
    this.types = const [],
    this.iconUrl,
    this.imageUrl,
  });

  /// Prefer [iconUrl], then [imageUrl] — both may be absent (UI uses 📍).
  String? get resolvedIconUrl {
    final icon = _nonEmpty(iconUrl);
    if (icon != null) return icon;
    return _nonEmpty(imageUrl);
  }

  factory PlaceSearchResultDto.fromJson(Map<String, dynamic> json) {
    return PlaceSearchResultDto(
      provider: json['provider'] as String? ?? 'GOOGLE',
      providerPlaceId: json['providerPlaceId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      formattedAddress: json['formattedAddress'] as String? ??
          json['subtitle'] as String? ??
          json['country'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      rating: (json['rating'] as num?)?.toDouble(),
      userRatingsTotal: json['userRatingsTotal'] as int?,
      googleMapsUri: json['googleMapsUri'] as String?,
      websiteUri: json['websiteUri'] as String?,
      types: (json['types'] as List<dynamic>?)?.cast<String>() ?? const [],
      iconUrl: _nonEmpty(json['iconUrl']),
      imageUrl: _nonEmpty(json['imageUrl']),
    );
  }

  static String? _nonEmpty(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }
}

class PlacesApiClient {
  final Dio _dio;

  PlacesApiClient(this._dio);

  /// Core `GET /places/autocomplete?q=` — after [ApiEnvelopeInterceptor],
  /// [Response.data] is the inner `data` (`{ items }` / `{ predictions }` /
  /// list). Also accepts a raw envelope when the interceptor is absent.
  Future<List<PlaceSearchResultDto>> searchPlaces(String query) async {
    final response = await _dio.get<dynamic>(
      '/places/autocomplete',
      queryParameters: {'q': query},
    );
    return _parseItems(response.data)
        .map(
          (e) => PlaceSearchResultDto.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();
  }

  Future<PlaceSearchResultDto?> getPlaceDetails(String providerPlaceId) async {
    final response = await _dio.get<dynamic>(
      '/places/$providerPlaceId',
    );
    final payload = _unwrapData(response.data);
    if (payload is! Map) return null;
    return PlaceSearchResultDto.fromJson(Map<String, dynamic>.from(payload));
  }

  /// Core `GET /places/hotels/autocomplete?q=` — lodging typeahead.
  /// Optional [latitude]/[longitude]/[radiusMeters] bias toward trip destination.
  Future<List<PlaceSearchResultDto>> searchHotelsAutocomplete(
    String query, {
    double? latitude,
    double? longitude,
    int? radiusMeters,
  }) async {
    final response = await _dio.get<dynamic>(
      '/places/hotels/autocomplete',
      queryParameters: {
        'q': query,
        if (latitude != null) 'lat': latitude,
        if (longitude != null) 'lng': longitude,
        if (radiusMeters != null) 'radiusMeters': radiusMeters,
      },
    );
    return _parseItems(response.data)
        .map(
          (e) => PlaceSearchResultDto.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();
  }

  /// Core `GET /places/hotels/search?q=` — lodging Text Search fallback.
  Future<List<PlaceSearchResultDto>> searchHotels(
    String query, {
    double? latitude,
    double? longitude,
  }) async {
    final response = await _dio.get<dynamic>(
      '/places/hotels/search',
      queryParameters: {
        'q': query,
        if (latitude != null) 'lat': latitude,
        if (longitude != null) 'lng': longitude,
      },
    );
    return _parseItems(response.data)
        .map(
          (e) => PlaceSearchResultDto.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();
  }

  /// Mirrors Home destinations parsing: list, `{ items }`, `{ predictions }`,
  /// or raw `{ success, data, timestamp }`.
  static List<dynamic> _parseItems(dynamic payload) {
    if (payload == null) return const [];

    if (payload is List) return payload;

    if (payload is Map) {
      final map = Map<String, dynamic>.from(payload);

      if (map.containsKey('data')) {
        final data = map['data'];
        if (data is Map) {
          final nested = Map<String, dynamic>.from(data);
          final items = nested['items'] ?? nested['predictions'];
          if (items is List) return items;
        }
        if (data is List) return data;
      }

      final items = map['items'] ?? map['predictions'];
      if (items is List) return items;
    }

    return const [];
  }

  static dynamic _unwrapData(dynamic payload) {
    if (payload is Map && payload.containsKey('data')) {
      return payload['data'];
    }
    return payload;
  }
}
