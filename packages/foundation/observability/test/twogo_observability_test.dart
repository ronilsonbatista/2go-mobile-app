import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_observability/twogo_observability.dart';

void main() {
  test('TwoGoObservability initialization test', () {
    const instance = TwoGoObservability();
    expect(instance, isNotNull);
  });
}
