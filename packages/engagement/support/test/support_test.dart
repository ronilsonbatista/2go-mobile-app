import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_support/support.dart';

void main() {
  test('TwoGoSupportModule initialization test', () {
    const module = TwoGoSupportModule();
    expect(module, isNotNull);
  });
}
