import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_vouchers/vouchers.dart';

void main() {
  test('TwoGoVouchersModule initialization test', () {
    const module = TwoGoVouchersModule();
    expect(module, isNotNull);
  });
}
