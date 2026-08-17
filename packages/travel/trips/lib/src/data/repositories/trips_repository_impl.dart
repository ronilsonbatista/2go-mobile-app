import '../../domain/entities/itinerary_item_entity.dart';
import '../../domain/entities/trip_day_entity.dart';
import '../../domain/entities/trip_entity.dart';
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
    final dto = await _remoteDataSource.addItineraryItem(dayId, {
      'title': item.title,
      'description': item.description,
      'category': item.category.name.toUpperCase(),
      'location': item.location,
      'period': item.period,
      'duration': item.duration,
      'cost': item.cost,
      'currency': item.currency,
      'order': item.order,
    });
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
}
