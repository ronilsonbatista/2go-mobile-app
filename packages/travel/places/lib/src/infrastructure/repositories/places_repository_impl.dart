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
      final mapped = results
          .map(
            (dto) => PlaceSearchResult(
              providerPlaceId: dto.providerPlaceId,
              name: dto.name,
              formattedAddress: dto.formattedAddress,
              latitude: dto.latitude,
              longitude: dto.longitude,
              types: dto.types,
            ),
          )
          .toList();
      return Result.success(mapped);
    } catch (error) {
      if (error is DioException) {
        return Result.failure(ErrorMapper.mapDioError(error));
      }
      return Result.failure(UnknownFailure(message: error.toString()));
    }
  }

  @override
  Future<Result<PlaceSearchResult?>> getPlaceDetails(
    String providerPlaceId,
  ) async {
    try {
      final dto = await _apiClient.getPlaceDetails(providerPlaceId);
      if (dto == null) return Result.success(null);

      final mapped = PlaceSearchResult(
        providerPlaceId: dto.providerPlaceId,
        name: dto.name,
        formattedAddress: dto.formattedAddress,
        latitude: dto.latitude,
        longitude: dto.longitude,
        types: dto.types,
      );
      return Result.success(mapped);
    } catch (error) {
      if (error is DioException) {
        return Result.failure(ErrorMapper.mapDioError(error));
      }
      return Result.failure(UnknownFailure(message: error.toString()));
    }
  }
}
