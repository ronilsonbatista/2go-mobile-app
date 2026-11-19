import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_trips/trips.dart';

void main() {
  group('VerifiedPlaceDetails Core PR #3 fields', () {
    test('parses hours, photos, reviews, editorial, priceLevelDisplay', () {
      final details = VerifiedPlaceDetails.fromJson({
        'name': 'Coliseu',
        'formattedAddress': 'Piazza del Colosseo, 1',
        'rating': 4.8,
        'userRatingsTotal': 1000,
        'priceLevel': 'PRICE_LEVEL_MODERATE',
        'priceLevelDisplay': '\$\$',
        'openingHoursText': '09:00-19:00',
        'editorialSummary': 'O maior anfiteatro do mundo.',
        'primaryType': 'tourist_attraction',
        'primaryTypeDisplayName': 'Ponto turístico',
        'latitude': 41.8902,
        'longitude': 12.4922,
        'photos': [
          {
            'name': 'places/x/photos/y',
            'photoUri': 'https://lh3.googleusercontent.com/photo',
          },
        ],
        'reviews': [
          {
            'rating': 4,
            'text': 'Experiência incrível',
            'authorName': 'Rachel Mendonça',
            'authorPhotoUri': 'https://example.com/a.jpg',
          },
        ],
      });

      expect(details.name, 'Coliseu');
      expect(details.priceLevelDisplay, '\$\$');
      expect(details.openingHoursText, '09:00-19:00');
      expect(details.editorialSummary, 'O maior anfiteatro do mundo.');
      expect(details.primaryTypeDisplayName, 'Ponto turístico');
      expect(details.photos, isNotNull);
      expect(details.photos!.single.photoUri,
          'https://lh3.googleusercontent.com/photo');
      expect(details.reviews!.single.authorName, 'Rachel Mendonça');
      expect(details.reviews!.single.authorPhotoUri,
          'https://example.com/a.jpg');
      expect(details.latitude, 41.8902);
      expect(details.hasAny, isTrue);
    });
  });

  group('formatPriceLevelDisplay', () {
    test('maps enum and int', () {
      expect(formatPriceLevelDisplay('PRICE_LEVEL_MODERATE'), '\$\$');
      expect(formatPriceLevelDisplay('3'), '\$\$\$');
      expect(formatPriceLevelDisplay('\$\$'), '\$\$');
      expect(formatPriceLevelDisplay('PRICE_LEVEL_FREE'), isNull);
      expect(formatPriceLevelDisplay(null), isNull);
    });
  });

  group('formatDurationHm', () {
    test('formats minutes', () {
      expect(formatDurationHm(50), '0:50');
      expect(formatDurationHm(90), '1:30');
      expect(formatDurationHm(0), '0:00');
    });
  });

  group('PlaceDetailsViewData.merge', () {
    test('prefers verified Maps facts and item editorial description', () {
      const item = ItineraryItemEntity(
        id: 'item-1',
        tripDayId: 'day-1',
        title: 'Coliseu',
        description:
            'O Coliseu, também chamado de Anfiteatro Flaviano, é o maior anfiteatro do mundo.',
        category: ItineraryCategory.touristAttraction,
        location: 'Roma',
        duration: 50,
        timeLabel: '11:05 - 11:50',
        ticketStatus: 'TICKET_REQUIRED',
        externalLink: 'https://tickets.example/coliseu',
        order: 0,
        providerPlaceId: 'ChIJ',
      );
      const verified = VerifiedPlaceDetails(
        name: 'Coliseu Romano',
        rating: 4.8,
        priceLevel: 'PRICE_LEVEL_MODERATE',
        priceLevelDisplay: '\$\$',
        openingHoursText: '09:00-19:00',
        formattedAddress: 'Piazza del Colosseo, 1',
        editorialSummary: 'Fallback editorial',
        websiteUri: 'https://colosseo.it',
        photos: [
          PlacePhoto(photoUri: 'https://lh3.googleusercontent.com/photo'),
        ],
        reviews: [
          PlaceReview(
            authorName: 'Rachel Mendonça',
            rating: 4,
            text: 'Incrível',
          ),
        ],
        latitude: 41.89,
        longitude: 12.49,
      );

      final view = PlaceDetailsViewData.merge(
        item: item,
        verified: verified,
        mode: PlaceDetailsMode.edit,
      );

      expect(view.displayName, 'Coliseu Romano');
      expect(view.description, contains('Anfiteatro Flaviano'));
      expect(view.rating, 4.8);
      expect(view.priceLevelDisplay, '\$\$');
      expect(view.openingHoursText, '09:00-19:00');
      expect(view.address, 'Piazza del Colosseo, 1');
      expect(view.photoUrls.single, contains('googleusercontent'));
      expect(view.reviews.single.authorName, 'Rachel Mendonça');
      expect(view.externalLinkLabel, 'Compra ingresso');
      expect(view.externalLinkUri, 'https://tickets.example/coliseu');
      expect(view.kind, PlaceDetailsKind.attraction);
      expect(view.durationMinutes, 50);
      expect(formatDurationHm(view.durationMinutes), '0:50');
    });

    test('restaurant pick CTA and site oficial', () {
      const item = ItineraryItemEntity(
        id: 'r1',
        tripDayId: 'day-1',
        title: 'Tonnarello',
        description: 'Restaurante em Trastevere.',
        category: ItineraryCategory.restaurant,
        order: 0,
        providerPlaceId: 'ChIJ-rest',
      );
      const verified = VerifiedPlaceDetails(
        name: 'Tonnarello',
        rating: 4.9,
        priceLevelDisplay: '\$\$',
        openingHoursText: '12:00-23:00',
        cuisineType: 'Italiana, Mediterrânea',
        websiteUri: 'https://tonnarello.example',
      );

      final view = PlaceDetailsViewData.merge(
        item: item,
        verified: verified,
        mode: PlaceDetailsMode.pick,
      );

      expect(view.kind, PlaceDetailsKind.restaurant);
      expect(view.selectCtaLabel, 'Selecionar restaurante');
      expect(view.externalLinkLabel, 'Site oficial');
      expect(view.cuisineTags, 'Italiana, Mediterrânea');
    });

    test('detects meal slot without providerPlaceId', () {
      const item = ItineraryItemEntity(
        id: 'm1',
        tripDayId: 'day-1',
        title: 'Almoço',
        category: ItineraryCategory.restaurant,
        duration: 90,
        period: 'Almoço',
        order: 0,
      );

      final view = PlaceDetailsViewData.merge(
        item: item,
        verified: null,
        mode: PlaceDetailsMode.edit,
      );

      expect(view.isMealSlot, isTrue);
      expect(view.kind, PlaceDetailsKind.mealSlot);
    });
  });
}
