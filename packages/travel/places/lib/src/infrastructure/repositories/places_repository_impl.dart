import 'package:app_roteiros_api/app_roteiros_api.dart';
import 'package:dio/dio.dart';
import 'package:twogo_core/twogo_core.dart';
import 'package:twogo_networking/twogo_networking.dart';
import '../../domain/models/place_search_result.dart';
import '../../domain/repositories/places_repository.dart';

class PlacesRepositoryImpl implements PlacesRepository {
  final PlacesApiClient _apiClient;

  PlacesRepositoryImpl({required PlacesApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<Result<List<PlaceSearchResult>>> searchPlaces(String query) async {
    try {
      final results = await _apiClient.searchPlaces(query);
      return Result.success(results.map(_mapDto).toList());
    } catch (error) {
      return _failure(error);
    }
  }

  @override
  Future<Result<List<PlaceSearchResult>>> searchHotelsAutocomplete(
    String query, {
    double? latitude,
    double? longitude,
    int? radiusMeters,
  }) async {
    try {
      final results = await _apiClient.searchHotelsAutocomplete(
        query,
        latitude: latitude,
        longitude: longitude,
        radiusMeters: radiusMeters,
      );
      return Result.success(results.map(_mapDto).toList());
    } catch (error) {
      return _failure(error);
    }
  }

  @override
  Future<Result<List<PlaceSearchResult>>> searchHotels(
    String query, {
    double? latitude,
    double? longitude,
  }) async {
    try {
      final results = await _apiClient.searchHotels(
        query,
        latitude: latitude,
        longitude: longitude,
      );
      return Result.success(results.map(_mapDto).toList());
    } catch (error) {
      return _failure(error);
    }
  }

  @override
  Future<Result<PlaceSearchResult?>> getPlaceDetails(
    String providerPlaceId,
  ) async {
    try {
      final dto = await _apiClient.getPlaceDetails(providerPlaceId);
      if (dto == null) return Result.success(null);
      return Result.success(_mapDto(dto));
    } catch (error) {
      return _failure(error);
    }
  }

  PlaceSearchResult _mapDto(PlaceSearchResultDto dto) {
    return PlaceSearchResult(
      providerPlaceId: dto.providerPlaceId,
      name: dto.name,
      formattedAddress: dto.formattedAddress,
      latitude: dto.latitude,
      longitude: dto.longitude,
      types: dto.types,
      iconUrl: dto.resolvedIconUrl,
    );
  }

  Result<T> _failure<T>(Object error) {
    if (error is DioException) {
      return Result.failure(ErrorMapper.mapDioError(error));
    }
    return Result.failure(UnknownFailure(message: error.toString()));
  }
}
