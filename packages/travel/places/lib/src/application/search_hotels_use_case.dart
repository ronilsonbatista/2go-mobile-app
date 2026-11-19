import 'package:twogo_core/twogo_core.dart';
import '../domain/models/place_search_result.dart';
import '../domain/repositories/places_repository.dart';

/// Prefer hotels autocomplete; fall back to hotels search when autocomplete
/// returns an empty list (Core still reachable). Failures from autocomplete
/// are returned as-is (no silent fallback on 502).
class SearchHotelsUseCase {
  final PlacesRepository _repository;

  SearchHotelsUseCase({required PlacesRepository repository})
    : _repository = repository;

  Future<Result<List<PlaceSearchResult>>> call(
    String query, {
    double? latitude,
    double? longitude,
    int? radiusMeters,
  }) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) {
      return Result.success(const []);
    }

    final autocomplete = await _repository.searchHotelsAutocomplete(
      trimmed,
      latitude: latitude,
      longitude: longitude,
      radiusMeters: radiusMeters,
    );
    if (autocomplete.isFailure) return autocomplete;

    final items = autocomplete.getOrNull() ?? const <PlaceSearchResult>[];
    if (items.isNotEmpty) return autocomplete;

    return _repository.searchHotels(
      trimmed,
      latitude: latitude,
      longitude: longitude,
    );
  }
}
