import '../../domain/entities/itinerary_item_entity.dart';
import '../../domain/entities/trip_day_entity.dart';
import '../../domain/entities/trip_entity.dart';
import '../../domain/paid_trip_controls.dart';
import '../../domain/repositories/trips_repository.dart';
import '../datasources/trips_remote_datasource.dart';

class TripsRepositoryImpl implements TripsRepository {
  final TripsRemoteDataSource _remoteDataSource;

  TripsRepositoryImpl({required TripsRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<List<TripEntity>> getMyTrips() async {
    final dtos = await _remoteDataSource.getMyTrips();
    return dtos.map((d) => d.toEntity()).toList();
  }

  @override
  Future<TripEntity> getTripById(String id) async {
    final dto = await _remoteDataSource.getTripById(id);
    return dto.toEntity();
  }

  @override
  Future<TripEntity> createTrip({
    required String title,
    required String destination,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final dto = await _remoteDataSource.createTrip({
      'title': title,
      'destination': destination,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
    });
    return dto.toEntity();
  }

  @override
  Future<TripEntity> updateTrip(TripEntity trip) async {
    final dto = await _remoteDataSource.updateTrip(trip.id, {
      'title': trip.title,
      'destination': trip.destination,
      'coverImage': trip.coverImage,
      'startDate': trip.startDate?.toIso8601String(),
      'endDate': trip.endDate?.toIso8601String(),
      'status': trip.status.name.toUpperCase(),
    });
    return dto.toEntity();
  }

  @override
  Future<void> deleteTrip(String id) async {
    await _remoteDataSource.deleteTrip(id);
  }

  @override
  Future<TripDayEntity> addTripDay(
    String tripId,
    int dayNumber, {
    String? title,
  }) async {
    final dto = await _remoteDataSource.addTripDay(tripId, {
      'dayNumber': dayNumber,
      'title': title,
    });
    return dto.toEntity();
  }

  @override
  Future<ItineraryItemEntity> addItineraryItem(
    String dayId,
    ItineraryItemEntity item,
  ) async {
    final body = <String, dynamic>{
      'title': item.title,
      'category': item.category.name.toUpperCase(),
      'order': item.order,
    };
    final description = item.description?.trim();
    if (description != null && description.isNotEmpty) {
      body['description'] = description;
    }
    final location = item.location?.trim();
    if (location != null && location.isNotEmpty) body['location'] = location;
    final period = item.period?.trim();
    if (period != null && period.isNotEmpty) body['period'] = period;
    if (item.duration != null) body['duration'] = item.duration;
    if (item.cost != null) body['cost'] = item.cost;
    final currency = item.currency?.trim();
    if (currency != null && currency.isNotEmpty) body['currency'] = currency;
    final placeId = item.providerPlaceId?.trim();
    if (placeId != null && placeId.isNotEmpty) {
      body['providerPlaceId'] = placeId;
      body['placeProvider'] = 'GOOGLE';
    }
    if (item.latitude != null) body['latitude'] = item.latitude;
    if (item.longitude != null) body['longitude'] = item.longitude;
    final maps = item.googleMapsLink?.trim();
    if (maps != null && maps.isNotEmpty) body['googleMapsLink'] = maps;
    final dto = await _remoteDataSource.addItineraryItem(dayId, body);
    return dto.toEntity();
  }

  @override
  Future<ItineraryItemEntity> updateItineraryItem(
    ItineraryItemEntity item,
  ) async {
    final dto = await _remoteDataSource.updateItineraryItem(item.id, {
      'tripDayId': item.tripDayId,
      'title': item.title,
      'description': item.description,
      'category': item.category.name.toUpperCase(),
      'order': item.order,
    });
    return dto.toEntity();
  }

  @override
  Future<void> deleteItineraryItem(String itemId) async {
    await _remoteDataSource.deleteItineraryItem(itemId);
  }

  @override
  Future<void> reorderItineraryItem(String itemId, int newOrder) async {
    await _remoteDataSource.reorderItineraryItem(itemId, newOrder);
  }

  @override
  Future<TripEntity> generateAiItinerary(
    String tripId,
    Map<String, dynamic> preferences,
  ) async {
    final dto = await _remoteDataSource.generateAiItinerary(
      tripId,
      preferences,
    );
    return dto.toEntity();
  }

  @override
  Future<AccommodationDraft?> getAccommodation(String tripId) {
    return _remoteDataSource.getAccommodation(tripId);
  }

  @override
  Future<AccommodationDraft> saveAccommodation(
    String tripId,
    AccommodationDraft stay,
  ) {
    return _remoteDataSource.saveAccommodation(tripId, stay);
  }

  @override
  Future<void> deleteAccommodation(String tripId) {
    return _remoteDataSource.deleteAccommodation(tripId);
  }

  @override
  Future<AlternativesResult> getItemAlternatives(
    String itemId, {
    AlternativesFilter filter = AlternativesFilter.empty,
  }) {
    return _remoteDataSource.getItemAlternatives(itemId, filter: filter);
  }

  @override
  Future<SwapQuota> substituteItem(String itemId, Map<String, dynamic> body) {
    return _remoteDataSource.substituteItem(itemId, body);
  }

  @override
  Future<MealRecommendationsResult> getMealRecommendations(
    String dayId, {
    String? period,
  }) {
    return _remoteDataSource.getMealRecommendations(dayId, period: period);
  }

  @override
  Future<void> pinMeal(String itemId, Map<String, dynamic> body) {
    return _remoteDataSource.pinMeal(itemId, body);
  }

  @override
  Future<void> unpinMeal(String itemId) {
    return _remoteDataSource.unpinMeal(itemId);
  }

  @override
  Future<void> updateItemDuration(String itemId, int duration) {
    return _remoteDataSource.updateItemDuration(itemId, duration);
  }

  @override
  Future<VerifiedPlaceDetails?> getVerifiedDetails(String itemId) {
    return _remoteDataSource.getVerifiedDetails(itemId);
  }
}
