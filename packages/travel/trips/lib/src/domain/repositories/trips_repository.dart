import '../entities/itinerary_item_entity.dart';
import '../entities/trip_day_entity.dart';
import '../entities/trip_entity.dart';
import '../paid_trip_controls.dart';

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

  Future<AccommodationDraft?> getAccommodation(String tripId);
  Future<AccommodationDraft> saveAccommodation(
    String tripId,
    AccommodationDraft stay,
  );
  Future<void> deleteAccommodation(String tripId);
  Future<AlternativesResult> getItemAlternatives(String itemId);
  Future<SwapQuota> substituteItem(String itemId, Map<String, dynamic> body);
  Future<MealRecommendationsResult> getMealRecommendations(
    String dayId, {
    String? period,
  });
  Future<void> pinMeal(String itemId, Map<String, dynamic> body);
  Future<void> updateItemDuration(String itemId, int duration);
  Future<VerifiedPlaceDetails?> getVerifiedDetails(String itemId);
}
