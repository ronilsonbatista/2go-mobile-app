import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_networking/twogo_networking.dart';
import 'package:twogo_security/twogo_security.dart';

class MockTokenStorage implements TokenStorage {
  @override
  Future<void> saveTokens(AuthTokens tokens) async {}

  @override
  Future<AuthTokens?> readTokens() async {
    return const AuthTokens(
      accessToken: 'valid_access_token',
      refreshToken: 'valid_refresh_token',
    );
  }

  @override
  Future<void> clearTokens() async {}
}

class MockRefreshCoordinator implements RefreshCoordinator {
  int refreshCalls = 0;

  @override
  int get refreshCallCount => refreshCalls;

  @override
  Future<AuthTokens> handleRefresh() async {
    refreshCalls++;
    return const AuthTokens(
      accessToken: 'new_access_token',
      refreshToken: 'new_refresh_token',
    );
  }
}

void main() {
  late MockTokenStorage tokenStorage;
  late MockRefreshCoordinator refreshCoordinator;
  late Dio dio;

  setUp(() {
    tokenStorage = MockTokenStorage();
    refreshCoordinator = MockRefreshCoordinator();
    dio = Dio();
    dio.interceptors.add(
      AuthInterceptor(
        tokenStorage: tokenStorage,
        refreshCoordinator: refreshCoordinator,
      ),
    );
  });

  group('JWT Refresh Isolation Tests for Guest Planning', () {
    test(
      '401 from /planning-sessions endpoint MUST NOT trigger JWT RefreshCoordinator (refreshCalls == 0)',
      () async {
        final err = DioException(
          requestOptions: RequestOptions(
            path: '/planning-sessions/journey-123',
            extra: {'isGuestRequest': true},
          ),
          response: Response(
            requestOptions: RequestOptions(
              path: '/planning-sessions/journey-123',
            ),
            statusCode: 401,
            data: {
              'code': 'PLANNING_JOURNEY_EXPIRED',
              'message': 'Sessão expirada',
            },
          ),
        );

        try {
          await dio.fetch<void>(err.requestOptions);
        } catch (_) {
          // Expected exception
        }

        expect(refreshCoordinator.refreshCalls, 0);
      },
    );
  });
}
