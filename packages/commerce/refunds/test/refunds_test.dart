import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_refunds/refunds.dart';

void main() {
  test('TwoGoRefundsModule initialization test', () {
    const module = TwoGoRefundsModule();
    expect(module, isNotNull);
  });
}
