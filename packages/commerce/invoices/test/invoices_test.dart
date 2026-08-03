import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_invoices/invoices.dart';

void main() {
  test('TwoGoInvoicesModule initialization test', () {
    const module = TwoGoInvoicesModule();
    expect(module, isNotNull);
  });
}
