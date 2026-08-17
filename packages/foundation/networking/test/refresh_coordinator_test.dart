import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_networking/networking.dart';
import 'package:twogo_security/twogo_security.dart';
import 'package:twogo_test_support/test_support.dart';

void main() {
  group('RefreshCoordinator Single-Flight Concurrency Tests', () {
    late TokenStorage storage;

    setUp(() {
      storage = InMemoryTokenStorage(
        const AuthTokens(
          accessToken: 'expired_access_token',
          refreshToken: 'initial_refresh_token',
        ),
      );
    });

    test(
      '10 CONCURRENT 401 REQUESTS MUST EXECUTE EXACTLY 1 REFRESH CALL',
      () async {
        int refreshCallCount = 0;

        Future<AuthTokens> mockRefreshFunction(String refreshToken) async {
          refreshCallCount++;
          await Future<void>.delayed(const Duration(milliseconds: 50));
          return AuthTokens(
            accessToken: 'new_access_token_$refreshCallCount',
            refreshToken: 'new_refresh_token_$refreshCallCount',
          );
        }

        final coordinator = RefreshCoordinator(
          tokenStorage: storage,
          refreshFunction: mockRefreshFunction,
        );

        // Launch 10 concurrent 401 refresh requests simultaneously
        final futures = List.generate(10, (_) => coordinator.handleRefresh());
        final results = await Future.wait(futures);

        // CRITICAL ASSERTIONS
        expect(refreshCallCount, equals(1));
        expect(coordinator.refreshCallCount, equals(1));

        for (final tokens in results) {
          expect(tokens.accessToken, equals('new_access_token_1'));
          expect(tokens.refreshToken, equals('new_refresh_token_1'));
        }

        final storedTokens = await storage.readTokens();
        expect(storedTokens!.accessToken, equals('new_access_token_1'));
      },
    );

    test('Refresh failure clears tokens and rethrows without loop', () async {
      int refreshCallCount = 0;

      Future<AuthTokens> failingRefreshFunction(String refreshToken) async {
        refreshCallCount++;
        await Future<void>.delayed(const Duration(milliseconds: 20));
        throw Exception('Refresh token revoked or invalid');
      }

      final coordinator = RefreshCoordinator(
        tokenStorage: storage,
        refreshFunction: failingRefreshFunction,
      );

      final futures = List.generate(5, (_) => coordinator.handleRefresh());

      for (final f in futures) {
        expect(f, throwsA(isA<Exception>()));
      }

      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(refreshCallCount, equals(1));

      final storedTokens = await storage.readTokens();
      expect(storedTokens, isNull);
    });
  });
}
