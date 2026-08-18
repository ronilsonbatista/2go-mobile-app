import 'package:twogo_core/twogo_core.dart';
import '../domain/models/place_search_result.dart';
import '../domain/repositories/places_repository.dart';

class SearchPlacesUseCase {
  final PlacesRepository _repository;

  SearchPlacesUseCase({required PlacesRepository repository})
    : _repository = repository;

  Future<Result<List<PlaceSearchResult>>> call(String query) async {
    if (query.trim().isEmpty) {
      return Result.success(const []);
    }
    return await _repository.searchPlaces(query);
  }
}
