import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_home/twogo_home.dart';
import 'package:twogo_planning/twogo_planning.dart';

/// Mirrors [HomePage] seed → draft contract used before pushing `/planning/wizard`.
void main() {
  group('Home destination prefill → users-defaults', () {
    late InMemoryPlanningDraftStorage draftStorage;
    late SeedHomeDestinationDraftUseCase seed;

    setUp(() {
      draftStorage = InMemoryPlanningDraftStorage();
      seed = SeedHomeDestinationDraftUseCase(draftStorage: draftStorage);
    });

    test('hero/strip destination seeds providerPlaceId for Onde restore', () async {
      const destination = HomeDestination(
        id: 'nova-york',
        name: 'Nova York',
        country: 'EUA',
        imageUrl: 'https://cdn.example/ny-hero.jpg',
        cardImageUrl: 'https://cdn.example/ny-card.jpg',
        providerPlaceId: 'places/ChIJOvpAl58aOxMRrdOveE7PaDI',
      );

      await seed(
        name: destination.name,
        country: destination.country,
        coverImageUrl:
            destination.resolvedCardUrl ?? destination.resolvedHeroUrl,
        providerPlaceId: destination.providerPlaceId,
      );

      final draft = await draftStorage.readDraft();
      expect(draft, isNotNull);
      expect(draft!.activeJourneyId, isNull);
      expect(draft.currentStep, 1);

      final stored = PlanningDestination.fromJson(draft.destinations!.single);
      expect(stored.name, 'Nova York');
      expect(stored.country, 'EUA');
      expect(stored.providerPlaceId, 'places/ChIJOvpAl58aOxMRrdOveE7PaDI');
      expect(stored.coverImage, 'https://cdn.example/ny-card.jpg');
      expect(stored.arrivalDate, isEmpty);
      expect(stored.departureDate, isEmpty);
    });

    test('CTA startEmpty does not keep a previously seeded city', () async {
      await seed(
        name: 'Capadócia',
        country: 'Turquia',
        providerPlaceId: 'places/ChIJcapadocia',
      );
      await seed.startEmpty();

      final draft = await draftStorage.readDraft();
      final stored = PlanningDestination.fromJson(draft!.destinations!.single);
      expect(stored.name, isEmpty);
      expect(stored.providerPlaceId, isNull);
    });
  });
}
