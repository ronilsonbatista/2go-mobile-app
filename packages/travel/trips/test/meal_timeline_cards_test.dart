import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_trips/trips.dart';

void main() {
  test('decodeMealPinNotes reads rating and priceRange', () {
    final meta = decodeMealPinNotes(
      '2go-meal-pin:{"dish":"Carbonara","rating":4.7,"priceRange":"\$\$"}',
    );
    expect(meta?.dish, 'Carbonara');
    expect(meta?.rating, 4.7);
    expect(meta?.priceRange, '\$\$');
  });

  test('MealTimelineCard.fromItineraryItem marks generic slot unselected', () {
    const item = ItineraryItemEntity(
      id: '1',
      tripDayId: 'd1',
      title: 'Almoço',
      category: ItineraryCategory.restaurant,
      order: 0,
      period: 'Almoço',
    );
    final card = MealTimelineCard.fromItineraryItem(item);
    expect(card.selected, isFalse);
  });

  test('MealTimelineCard.fromItineraryItem marks pinned place selected', () {
    const item = ItineraryItemEntity(
      id: '1',
      tripDayId: 'd1',
      title: 'Tonnarello',
      category: ItineraryCategory.restaurant,
      order: 0,
      providerPlaceId: 'ChIJ',
      externalLink: 'https://cdn.example/x.jpg',
      notes: '2go-meal-pin:{"rating":4.9,"priceRange":"\$\$\$"}',
      timeLabel: '20:00 - 21:50',
    );
    final card = MealTimelineCard.fromItineraryItem(item);
    expect(card.selected, isTrue);
    expect(card.rating, 4.9);
    expect(card.priceRange, '\$\$\$');
  });
}
