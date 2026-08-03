import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_authentication/authentication.dart';

void main() {
  test('TwoGoAuthenticationModule initialization test', () {
    const module = TwoGoAuthenticationModule();
    expect(module, isNotNull);
  });
}
