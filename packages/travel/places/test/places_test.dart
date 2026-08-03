import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_places/places.dart';

void main() {
  test('TwoGoPlacesModule initialization test', () {
    const module = TwoGoPlacesModule();
    expect(module, isNotNull);
  });
}
