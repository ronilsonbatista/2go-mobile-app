import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_trips/trips.dart';

void main() {
  group(
    'Trips Package Tests (app-roteiros-core Trip/Day/Itinerary contracts)',
    () {
      late MockTripsDataSource mockDataSource;
      late TripsRepositoryImpl tripsRepository;
      late TripsCubit tripsCubit;

      setUp(() {
        mockDataSource = MockTripsDataSource();
        tripsRepository = TripsRepositoryImpl(remoteDataSource: mockDataSource);
        tripsCubit = TripsCubit(tripsRepository: tripsRepository);
      });

      tearDown(() {
        tripsCubit.dispose();
      });

      test(
        'loadMyTrips loads user trips with days and itinerary items',
        () async {
          await tripsCubit.loadMyTrips();

          expect(tripsCubit.value.status, TripsStatus.loaded);
          expect(tripsCubit.value.trips, isNotEmpty);

          final trip = tripsCubit.value.trips.first;
          expect(trip.destination, contains('Paris'));
          expect(trip.days, isNotEmpty);

          final firstDay = trip.days.first;
          expect(firstDay.dayNumber, 1);
          expect(firstDay.items, isNotEmpty);

          final firstItem = firstDay.items.first;
          expect(firstItem.title, contains('Louvre'));
          expect(firstItem.category, ItineraryCategory.museum);
        },
      );

      test('createTrip adds new trip to user list', () async {
        await tripsCubit.createTrip('Férias em Tóquio', 'Tóquio, Japão');

        expect(tripsCubit.value.status, TripsStatus.loaded);
        expect(
          tripsCubit.value.trips.any((t) => t.title == 'Férias em Tóquio'),
          isTrue,
        );
      });

      test('addItineraryItem adds activity to day', () async {
        const newItem = ItineraryItemEntity(
          id: 'new_item',
          tripDayId: 'day_paris_1',
          title: 'Almoço no Bistrô',
          category: ItineraryCategory.restaurant,
          order: 3,
        );

        final result = await tripsRepository.addItineraryItem(
          'day_paris_1',
          newItem,
        );
        expect(result.title, 'Almoço no Bistrô');
        expect(result.category, ItineraryCategory.restaurant);
      });
    },
  );
}
