import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_core/twogo_core.dart';

void main() {
  test('TwoGoCore initialization test', () {
    const instance = TwoGoCore();
    expect(instance, isNotNull);
  });
}
