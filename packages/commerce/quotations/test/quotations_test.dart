import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_quotations/quotations.dart';

void main() {
  test('TwoGoQuotationsModule initialization test', () {
    const module = TwoGoQuotationsModule();
    expect(module, isNotNull);
  });
}
