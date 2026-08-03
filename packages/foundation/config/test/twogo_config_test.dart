import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_config/twogo_config.dart';

void main() {
  test('TwoGoConfig initialization test', () {
    const instance = TwoGoConfig();
    expect(instance, isNotNull);
  });
}
