import 'package:twogo_core/twogo_core.dart';
import '../models/place_search_result.dart';

abstract class PlacesRepository {
  Future<Result<List<PlaceSearchResult>>> searchPlaces(String query);

  /// Lodging typeahead — Core `GET /places/hotels/autocomplete`.
  Future<Result<List<PlaceSearchResult>>> searchHotelsAutocomplete(
    String query, {
    double? latitude,
    double? longitude,
    int? radiusMeters,
  });

  /// Lodging Text Search — Core `GET /places/hotels/search` (fallback).
  Future<Result<List<PlaceSearchResult>>> searchHotels(
    String query, {
    double? latitude,
    double? longitude,
  });

  Future<Result<PlaceSearchResult?>> getPlaceDetails(String providerPlaceId);
}
