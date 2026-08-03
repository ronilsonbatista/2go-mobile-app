import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_bookings/bookings.dart';

void main() {
  test('TwoGoBookingsModule initialization test', () {
    const module = TwoGoBookingsModule();
    expect(module, isNotNull);
  });
}
