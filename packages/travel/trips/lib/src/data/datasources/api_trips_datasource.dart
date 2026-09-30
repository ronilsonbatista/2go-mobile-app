import 'package:dio/dio.dart';

import '../../domain/paid_trip_controls.dart';
import '../models/itinerary_item_dto.dart';
import '../models/trip_day_dto.dart';
import '../models/trip_dto.dart';
import 'trips_remote_datasource.dart';

/// Cliente da viagem paga: `GET /trips/:id` e os controles da Fase 3.
class ApiTripsDataSource implements TripsRemoteDataSource {
  ApiTripsDataSource(this._dio);

  final Dio _dio;

  static final UnsupportedError _missingEndpoint = UnsupportedError(
    'Este endpoint não existe no cliente. A aba usa GET /trips/:id e os controles da Fase 3.',
  );

  @override
  Future<TripDto> getTripById(String id) async {
    final response = await _dio.get<dynamic>(
      '/trips/${Uri.encodeComponent(id)}',
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return TripDto.fromJson(data);
    }
    if (data is Map) {
      return TripDto.fromJson(Map<String, dynamic>.from(data));
    }
    throw const FormatException('GET /trips/:id não devolveu um objeto');
  }

  @override
  Future<List<TripDto>> getMyTrips() =>
      Future<List<TripDto>>.error(_missingEndpoint);

  @override
  Future<TripDto> createTrip(Map<String, dynamic> body) =>
      Future<TripDto>.error(_missingEndpoint);

  @override
  Future<TripDto> updateTrip(String id, Map<String, dynamic> body) =>
      Future<TripDto>.error(_missingEndpoint);

  @override
  Future<void> deleteTrip(String id) => Future<void>.error(_missingEndpoint);

  @override
  Future<TripDayDto> addTripDay(String tripId, Map<String, dynamic> body) =>
      Future<TripDayDto>.error(_missingEndpoint);

  @override
  Future<ItineraryItemDto> addItineraryItem(
    String dayId,
    Map<String, dynamic> body,
  ) => Future<ItineraryItemDto>.error(_missingEndpoint);

  @override
  Future<ItineraryItemDto> updateItineraryItem(
    String id,
    Map<String, dynamic> body,
  ) => Future<ItineraryItemDto>.error(_missingEndpoint);

  @override
  Future<void> deleteItineraryItem(String id) =>
      Future<void>.error(_missingEndpoint);

  @override
  Future<void> reorderItineraryItem(String id, int newOrder) =>
      Future<void>.error(_missingEndpoint);

  @override
  Future<TripDto> generateAiItinerary(
    String tripId,
    Map<String, dynamic> preferences,
  ) => Future<TripDto>.error(_missingEndpoint);

  @override
  Future<AccommodationDraft?> getAccommodation(String tripId) async {
    final response = await _dio.get<dynamic>(_accommodationPath(tripId));
    final data = response.data;
    if (data == null) return null;
    return AccommodationDraft.fromJson(
      _asMap(data, 'GET /trips/:id/accommodation'),
    );
  }

  @override
  Future<AccommodationDraft> saveAccommodation(
    String tripId,
    AccommodationDraft stay,
  ) async {
    final response = await _dio.post<dynamic>(
      _accommodationPath(tripId),
      data: stay.toJson(),
    );
    return AccommodationDraft.fromJson(
      _asMap(response.data, 'POST /trips/:id/accommodation'),
    );
  }

  @override
  Future<void> deleteAccommodation(String tripId) async {
    await _dio.delete<dynamic>(_accommodationPath(tripId));
  }

  @override
  Future<AlternativesResult> getItemAlternatives(String itemId) async {
    final response = await _dio.get<dynamic>(
      '/itinerary-items/${_id(itemId)}/alternatives',
    );
    return AlternativesResult.fromJson(
      _asMap(response.data, 'GET /itinerary-items/:id/alternatives'),
    );
  }

  @override
  Future<SwapQuota> substituteItem(
    String itemId,
    Map<String, dynamic> body,
  ) async {
    final response = await _dio.post<dynamic>(
      '/itinerary-items/${_id(itemId)}/substitute',
      data: body,
    );
    final data = _asMap(response.data, 'POST /itinerary-items/:id/substitute');
    final quota = data['quota'];
    if (quota is Map) {
      return SwapQuota.fromJson(Map<String, dynamic>.from(quota));
    }
    return const SwapQuota();
  }

  @override
  Future<MealRecommendationsResult> getMealRecommendations(
    String dayId, {
    String? period,
  }) async {
    final query = period?.trim();
    final response = await _dio.get<dynamic>(
      '/trip-days/${_id(dayId)}/meal-recommendations',
      queryParameters: query == null || query.isEmpty
          ? null
          : <String, dynamic>{'period': query},
    );
    return MealRecommendationsResult.fromJson(
      _asMap(response.data, 'GET /trip-days/:id/meal-recommendations'),
    );
  }

  @override
  Future<void> pinMeal(String itemId, Map<String, dynamic> body) async {
    await _dio.patch<dynamic>(
      '/itinerary-items/${_id(itemId)}/pin-meal',
      data: body,
    );
  }

  @override
  Future<void> updateItemDuration(String itemId, int duration) async {
    await _dio.patch<dynamic>(
      '/itinerary-items/${_id(itemId)}',
      data: <String, dynamic>{'duration': duration},
    );
  }

  @override
  Future<VerifiedPlaceDetails?> getVerifiedDetails(String itemId) async {
    final response = await _dio.get<dynamic>('/itinerary-items/${_id(itemId)}');
    final data = _asMap(response.data, 'GET /itinerary-items/:id');
    if (!data.containsKey('verifiedDetails')) return null;
    final raw = data['verifiedDetails'];
    if (raw == null) return null;
    if (raw is! Map) return null;
    return VerifiedPlaceDetails.fromJson(Map<String, dynamic>.from(raw));
  }

  String _accommodationPath(String tripId) =>
      '/trips/${_id(tripId)}/accommodation';

  String _id(String id) => Uri.encodeComponent(id);
}

Map<String, dynamic> _asMap(dynamic data, String path) {
  if (data is Map<String, dynamic>) return data;
  if (data is Map) return Map<String, dynamic>.from(data);
  throw FormatException('$path não devolveu um objeto');
}
