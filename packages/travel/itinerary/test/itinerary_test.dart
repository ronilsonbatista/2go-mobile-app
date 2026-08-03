import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_itinerary/itinerary.dart';

void main() {
  test('TwoGoItineraryModule initialization test', () {
    const module = TwoGoItineraryModule();
    expect(module, isNotNull);
  });
}
