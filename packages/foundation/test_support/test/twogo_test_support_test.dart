import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_test_support/twogo_test_support.dart';

void main() {
  test('TwoGoTestSupport initialization test', () {
    final instance = InMemoryTokenStorage();
    expect(instance, isNotNull);
  });
}
