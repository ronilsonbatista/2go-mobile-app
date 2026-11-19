import 'package:twogo_core/twogo_core.dart';
import '../domain/models/place_search_result.dart';
import '../domain/repositories/places_repository.dart';

class GetPlaceDetailsUseCase {
  final PlacesRepository _repository;

  GetPlaceDetailsUseCase({required PlacesRepository repository})
    : _repository = repository;

  Future<Result<PlaceSearchResult?>> call(String providerPlaceId) {
    final id = providerPlaceId.trim();
    if (id.isEmpty) {
      return Future.value(Result.success(null));
    }
    return _repository.getPlaceDetails(id);
  }
}
