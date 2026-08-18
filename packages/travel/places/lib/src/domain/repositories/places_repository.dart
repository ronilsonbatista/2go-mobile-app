import 'package:twogo_core/twogo_core.dart';
import '../models/place_search_result.dart';

abstract class PlacesRepository {
  Future<Result<List<PlaceSearchResult>>> searchPlaces(String query);
  Future<Result<PlaceSearchResult?>> getPlaceDetails(String providerPlaceId);
}
