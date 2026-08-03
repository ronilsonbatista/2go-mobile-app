import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_maps/maps.dart';

void main() {
  test('TwoGoMapsModule initialization test', () {
    const module = TwoGoMapsModule();
    expect(module, isNotNull);
  });
}
