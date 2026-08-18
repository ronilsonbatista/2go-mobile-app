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
  });

  factory PlaceSearchResultDto.fromJson(Map<String, dynamic> json) {
    return PlaceSearchResultDto(
      provider: json['provider'] as String? ?? 'GOOGLE',
      providerPlaceId: json['providerPlaceId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      formattedAddress: json['formattedAddress'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      rating: (json['rating'] as num?)?.toDouble(),
      userRatingsTotal: json['userRatingsTotal'] as int?,
      googleMapsUri: json['googleMapsUri'] as String?,
      websiteUri: json['websiteUri'] as String?,
      types: (json['types'] as List<dynamic>?)?.cast<String>() ?? const [],
    );
  }
}

class PlacesApiClient {
  final Dio _dio;

  PlacesApiClient(this._dio);

  Future<List<PlaceSearchResultDto>> searchPlaces(String query) async {
    final response = await _dio.get<List<dynamic>>(
      '/places/search',
      queryParameters: {'query': query},
    );
    final data = response.data ?? [];
    return data
        .map((e) => PlaceSearchResultDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PlaceSearchResultDto?> getPlaceDetails(String providerPlaceId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/places/$providerPlaceId',
    );
    if (response.data == null) return null;
    return PlaceSearchResultDto.fromJson(response.data!);
  }
}
