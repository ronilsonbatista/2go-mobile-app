import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_test_support/twogo_test_support.dart';

void main() {
  test('TwoGoTestSupport initialization test', () {
    const instance = TwoGoTestSupport();
    expect(instance, isNotNull);
  });
}
