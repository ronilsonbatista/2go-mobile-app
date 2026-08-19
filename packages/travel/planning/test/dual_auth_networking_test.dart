import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_networking/twogo_networking.dart';
import 'package:twogo_security/twogo_security.dart';

class FakeTokenStorage implements TokenStorage {
  AuthTokens? tokens;

  FakeTokenStorage({this.tokens});

  @override
  Future<void> saveTokens(AuthTokens t) async {
    tokens = t;
  }

  @override
  Future<AuthTokens?> readTokens() async {
    return tokens;
  }

  @override
  Future<void> clearTokens() async {
    tokens = null;
  }
}

class FakeRefreshCoordinator implements RefreshCoordinator {
  final FakeTokenStorage tokenStorage;
  int refreshCalls = 0;
  bool shouldFail = false;

  FakeRefreshCoordinator(this.tokenStorage);

  @override
  int get refreshCallCount => refreshCalls;

  @override
  Future<AuthTokens> handleRefresh() async {
    refreshCalls++;
    if (shouldFail) {
      throw Exception('Session Expired');
    }
    const newTokens = AuthTokens(
      accessToken: 'new-access-token',
      refreshToken: 'new-refresh-token',
    );
    await tokenStorage.saveTokens(newTokens);
    return newTokens;
  }
}

void main() {
  late FakeTokenStorage tokenStorage;
  late FakeRefreshCoordinator refreshCoordinator;
  late Dio dio;

  setUp(() {
    tokenStorage = FakeTokenStorage(
      tokens: const AuthTokens(
        accessToken: 'initial-access-token',
        refreshToken: 'initial-refresh-token',
      ),
    );
    refreshCoordinator = FakeRefreshCoordinator(tokenStorage);

    dio = Dio(BaseOptions(baseUrl: 'https://api.2go.app'));
    dio.interceptors.add(
      AuthInterceptor(
        tokenStorage: tokenStorage,
        refreshCoordinator: refreshCoordinator,
      ),
    );
  });

  group('Dual Auth & Networking Isolation Tests', () {
    test(
        'DUAL AUTH HEADERS: claim request includes BOTH Authorization and X-Guest-Token',
        () async {
      late RequestOptions capturedOptions;

      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            capturedOptions = options;
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.cancel,
              ),
            );
          },
        ),
      );

      try {
        await dio.post<dynamic>(
          '/planning-sessions/journey-123/claim',
          options: Options(
            headers: {'X-Guest-Token': 'guest-secret-999'},
          ),
        );
      } catch (_) {}

      expect(capturedOptions.headers['Authorization'],
          'Bearer initial-access-token');
      expect(
          capturedOptions.headers['X-Guest-Token'], 'guest-secret-999');
    });

    test(
        'DUAL AUTH JWT REFRESH: 401 JWT error on /claim triggers RefreshCoordinator and retries with X-Guest-Token',
        () async {
      late RequestOptions retriedOptions;

      final interceptor = AuthInterceptor(
        tokenStorage: tokenStorage,
        refreshCoordinator: refreshCoordinator,
      );

      final reqOptions = RequestOptions(
        path: '/planning-sessions/journey-123/claim',
        headers: {'X-Guest-Token': 'guest-secret-999'},
      );
      reqOptions.extra['dioFetch'] = (RequestOptions retryOpts) async {
        retriedOptions = retryOpts;
        return Response<void>(requestOptions: retryOpts, statusCode: 200);
      };

      final err = DioException(
        requestOptions: reqOptions,
        response: Response(
          requestOptions: reqOptions,
          statusCode: 401,
          data: {'code': 'AUTH_SESSION_EXPIRED'},
        ),
      );

      final handler = ErrorInterceptorHandler();
      await interceptor.onError(err, handler);

      expect(refreshCoordinator.refreshCalls, 1);
      expect(retriedOptions.headers['Authorization'], 'Bearer new-access-token');
      expect(retriedOptions.headers['X-Guest-Token'], 'guest-secret-999');
    });

    test(
        'GUEST ERROR ISOLATION: 401 PLANNING_JOURNEY_INVALID_TOKEN on /claim skips JWT refresh (refreshCalls = 0)',
        () async {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                response: Response(
                  requestOptions: options,
                  statusCode: 401,
                  data: {
                    'code': 'PLANNING_JOURNEY_INVALID_TOKEN',
                    'message': 'Guest token inválido',
                  },
                ),
              ),
            );
          },
        ),
      );

      try {
        await dio.post<dynamic>(
          '/planning-sessions/journey-123/claim',
          options: Options(
            headers: {'X-Guest-Token': 'invalid-token'},
          ),
        );
      } catch (_) {}

      expect(refreshCoordinator.refreshCalls, 0);
    });

    test(
        'PURE GUEST ENDPOINTS: 401 on /preview skips JWT refresh and does not attach Authorization',
        () async {
      late RequestOptions capturedOptions;

      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            capturedOptions = options;
            handler.reject(
              DioException(
                requestOptions: options,
                response: Response(
                  requestOptions: options,
                  statusCode: 401,
                  data: {
                    'code': 'PLANNING_JOURNEY_EXPIRED',
                    'message': 'Guest session expirada',
                  },
                ),
              ),
            );
          },
        ),
      );

      try {
        await dio.get<dynamic>(
          '/planning-sessions/journey-123/preview',
          options: Options(
            headers: {'X-Guest-Token': 'guest-token'},
          ),
        );
      } catch (_) {}

      expect(capturedOptions.headers.containsKey('Authorization'), false);
      expect(refreshCoordinator.refreshCalls, 0);
    });
  });
}
