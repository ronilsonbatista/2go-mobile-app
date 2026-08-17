import '../entities/itinerary_item_entity.dart';
import '../entities/trip_day_entity.dart';
import '../entities/trip_entity.dart';

abstract class TripsRepository {
  Future<List<TripEntity>> getMyTrips();
  Future<TripEntity> getTripById(String id);
  Future<TripEntity> createTrip({
    required String title,
    required String destination,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<TripEntity> updateTrip(TripEntity trip);
  Future<void> deleteTrip(String id);
  Future<TripDayEntity> addTripDay(
    String tripId,
    int dayNumber, {
    String? title,
  });
  Future<ItineraryItemEntity> addItineraryItem(
    String dayId,
    ItineraryItemEntity item,
  );
  Future<ItineraryItemEntity> updateItineraryItem(ItineraryItemEntity item);
  Future<void> deleteItineraryItem(String itemId);
  Future<void> reorderItineraryItem(String itemId, int newOrder);
  Future<TripEntity> generateAiItinerary(
    String tripId,
    Map<String, dynamic> preferences,
  );
}
