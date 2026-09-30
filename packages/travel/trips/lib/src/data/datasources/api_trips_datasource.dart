import 'package:dio/dio.dart';

import '../models/itinerary_item_dto.dart';
import '../models/trip_day_dto.dart';
import '../models/trip_dto.dart';
import 'trips_remote_datasource.dart';

/// Cliente mínimo de viagem. O app só chama `GET /trips/:id`.
class ApiTripsDataSource implements TripsRemoteDataSource {
  ApiTripsDataSource(this._dio);

  final Dio _dio;

  static final UnsupportedError _missingEndpoint = UnsupportedError(
    'Este endpoint não existe no cliente. A aba usa apenas GET /trips/:id.',
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
}
