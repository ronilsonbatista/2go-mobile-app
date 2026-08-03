import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_checkout/checkout.dart';

void main() {
  test('TwoGoCheckoutModule initialization test', () {
    const module = TwoGoCheckoutModule();
    expect(module, isNotNull);
  });
}
