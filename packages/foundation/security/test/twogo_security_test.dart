import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_security/twogo_security.dart';

void main() {
  test('TwoGoSecurity initialization test', () {
    const tokens = AuthTokens(accessToken: 'acc', refreshToken: 'ref');
    expect(tokens, isNotNull);
  });
}
