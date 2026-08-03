import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_trips/trips.dart';

void main() {
  test('TwoGoTripsModule initialization test', () {
    const module = TwoGoTripsModule();
    expect(module, isNotNull);
  });
}
