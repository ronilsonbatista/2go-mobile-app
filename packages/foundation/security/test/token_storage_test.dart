import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_security/twogo_security.dart';
import 'package:twogo_test_support/test_support.dart';

void main() {
  group('TokenStorage Tests', () {
    late TokenStorage storage;

    setUp(() {
      storage = InMemoryTokenStorage();
    });

    test('save, read, replace and clear tokens', () async {
      expect(await storage.readTokens(), isNull);

      const tokens1 = AuthTokens(accessToken: 'acc_1', refreshToken: 'ref_1');
      await storage.saveTokens(tokens1);

      var read = await storage.readTokens();
      expect(read, equals(tokens1));
      expect(read.toString(), contains('[REDACTED]'));

      const tokens2 = AuthTokens(accessToken: 'acc_2', refreshToken: 'ref_2');
      await storage.saveTokens(tokens2);

      read = await storage.readTokens();
      expect(read, equals(tokens2));

      await storage.clearTokens();
      expect(await storage.readTokens(), isNull);
    });
  });
}
