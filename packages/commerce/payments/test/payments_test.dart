import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_payments/payments.dart';

void main() {
  test('TwoGoPaymentsModule initialization test', () {
    const module = TwoGoPaymentsModule();
    expect(module, isNotNull);
  });
}
