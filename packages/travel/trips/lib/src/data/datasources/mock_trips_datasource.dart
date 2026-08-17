import '../models/itinerary_item_dto.dart';
import '../models/trip_day_dto.dart';
import '../models/trip_dto.dart';
import 'trips_remote_datasource.dart';

class MockTripsDataSource implements TripsRemoteDataSource {
  final List<TripDto> _trips = [
    const TripDto(
      id: 't78a9c11-4e92-4110-8b01-f51948381180',
      userId: 'u49a21b3-5e18-4931-8544-a68394848a68',
      title: 'Minha Viagem para Paris',
      destination: 'Paris, França',
      coverImage:
          'https://images.unsplash.com/photo-1502602898657-3e91760cbb34',
      startDate: '2026-09-01T00:00:00.000Z',
      endDate: '2026-09-07T00:00:00.000Z',
      status: 'ACTIVE',
      premiumUnlockedAt: '2026-08-17T11:45:00.000Z',
      days: [
        TripDayDto(
          id: 'day_paris_1',
          tripId: 't78a9c11-4e92-4110-8b01-f51948381180',
          dayNumber: 1,
          date: '2026-09-01T00:00:00.000Z',
          title: 'Do Louvre à Torre Eiffel',
          description: 'Primeiro dia clássico em Paris',
          items: [
            ItineraryItemDto(
              id: 'item_louvre',
              tripDayId: 'day_paris_1',
              title: 'Visita Guiada ao Museu do Louvre',
              description: 'Obras de arte clássicas e Mona Lisa',
              category: 'MUSEUM',
              location: 'Rue de Rivoli, 75001 Paris',
              period: 'MANHA',
              duration: 180,
              cost: 22.0,
              currency: 'EUR',
              order: 1,
              providerPlaceId: 'ChIJLU7jZClu5kcR4PcD-5xMwVV',
            ),
            ItineraryItemDto(
              id: 'item_eiffel',
              tripDayId: 'day_paris_1',
              title: 'Pôr do Sol na Torre Eiffel',
              description: 'Vista panorâmica nos Jardins do Trocadéro',
              category: 'TOURIST_ATTRACTION',
              location: 'Champ de Mars, 75007 Paris',
              period: 'TARDE',
              duration: 120,
              cost: 28.0,
              currency: 'EUR',
              order: 2,
              providerPlaceId: 'ChIJLU7jZClu5kcR4PcD-5xMwVV2',
            ),
          ],
        ),
      ],
    ),
  ];

  @override
  Future<List<TripDto>> getMyTrips() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return List.from(_trips);
  }

  @override
  Future<TripDto> getTripById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final trip = _trips.firstWhere(
      (t) => t.id == id,
      orElse: () => _trips.first,
    );
    return trip;
  }

  @override
  Future<TripDto> createTrip(Map<String, dynamic> body) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final newId = 't_${DateTime.now().millisecondsSinceEpoch}';
    final newTrip = TripDto(
      id: newId,
      userId: 'u49a21b3-5e18-4931-8544-a68394848a68',
      title: body['title'] as String? ?? 'Nova Viagem',
      destination: body['destination'] as String? ?? 'Destino',
      startDate: body['startDate'] as String?,
      endDate: body['endDate'] as String?,
      status: 'DRAFT',
      days: const [],
    );
    _trips.add(newTrip);
    return newTrip;
  }

  @override
  Future<TripDto> updateTrip(String id, Map<String, dynamic> body) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final index = _trips.indexWhere((t) => t.id == id);
    if (index == -1) throw Exception('Viagem não encontrada');

    final old = _trips[index];
    final updated = TripDto(
      id: old.id,
      userId: old.userId,
      title: body['title'] as String? ?? old.title,
      destination: body['destination'] as String? ?? old.destination,
      coverImage: body['coverImage'] as String? ?? old.coverImage,
      startDate: body['startDate'] as String? ?? old.startDate,
      endDate: body['endDate'] as String? ?? old.endDate,
      status: body['status'] as String? ?? old.status,
      preferences: old.preferences,
      premiumUnlockedAt: old.premiumUnlockedAt,
      days: old.days,
    );
    _trips[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteTrip(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _trips.removeWhere((t) => t.id == id);
  }

  @override
  Future<TripDayDto> addTripDay(
    String tripId,
    Map<String, dynamic> body,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final dayId = 'day_${DateTime.now().millisecondsSinceEpoch}';
    return TripDayDto(
      id: dayId,
      tripId: tripId,
      dayNumber: body['dayNumber'] as int? ?? 1,
      title: body['title'] as String?,
      description: body['description'] as String?,
      items: const [],
    );
  }

  @override
  Future<ItineraryItemDto> addItineraryItem(
    String dayId,
    Map<String, dynamic> body,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final itemId = 'item_${DateTime.now().millisecondsSinceEpoch}';
    return ItineraryItemDto(
      id: itemId,
      tripDayId: dayId,
      title: body['title'] as String? ?? 'Atividade',
      description: body['description'] as String?,
      category: body['category'] as String? ?? 'TOURIST_ATTRACTION',
      location: body['location'] as String?,
      period: body['period'] as String?,
      duration: body['duration'] as int?,
      cost: (body['cost'] as num?)?.toDouble(),
      currency: body['currency'] as String?,
      order: body['order'] as int? ?? 1,
    );
  }

  @override
  Future<ItineraryItemDto> updateItineraryItem(
    String id,
    Map<String, dynamic> body,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return ItineraryItemDto(
      id: id,
      tripDayId: body['tripDayId'] as String? ?? 'day_1',
      title: body['title'] as String? ?? 'Atividade Atualizada',
      description: body['description'] as String?,
      category: body['category'] as String? ?? 'TOURIST_ATTRACTION',
      order: body['order'] as int? ?? 1,
    );
  }

  @override
  Future<void> deleteItineraryItem(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
  }

  @override
  Future<void> reorderItineraryItem(String id, int newOrder) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
  }

  @override
  Future<TripDto> generateAiItinerary(
    String tripId,
    Map<String, dynamic> preferences,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final trip = await getTripById(tripId);
    return trip;
  }
}
