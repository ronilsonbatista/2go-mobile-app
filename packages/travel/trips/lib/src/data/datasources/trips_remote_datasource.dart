import '../models/itinerary_item_dto.dart';
import '../models/trip_day_dto.dart';
import '../models/trip_dto.dart';

abstract class TripsRemoteDataSource {
  Future<List<TripDto>> getMyTrips();
  Future<TripDto> getTripById(String id);
  Future<TripDto> createTrip(Map<String, dynamic> body);
  Future<TripDto> updateTrip(String id, Map<String, dynamic> body);
  Future<void> deleteTrip(String id);
  Future<TripDayDto> addTripDay(String tripId, Map<String, dynamic> body);
  Future<ItineraryItemDto> addItineraryItem(
    String dayId,
    Map<String, dynamic> body,
  );
  Future<ItineraryItemDto> updateItineraryItem(
    String id,
    Map<String, dynamic> body,
  );
  Future<void> deleteItineraryItem(String id);
  Future<void> reorderItineraryItem(String id, int newOrder);
  Future<TripDto> generateAiItinerary(
    String tripId,
    Map<String, dynamic> preferences,
  );
}
