import 'package:app_roteiros_api/app_roteiros_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthApiClient', () {
    late Dio dio;
    late AuthApiClient client;
    String? path;
    String? method;
    dynamic body;

    setUp(() {
      path = null;
      method = null;
      body = null;
      dio = Dio(BaseOptions(baseUrl: 'https://core.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            path = options.path;
            method = options.method;
            body = options.data;
            handler.resolve(
              Response<Map<String, dynamic>>(
                requestOptions: options,
                statusCode: 200,
                data: _unwrappedTokens(),
              ),
            );
          },
        ),
      );
      client = AuthApiClient(dio);
    });

    test('POST /auth/otp/request sends email body and returns map', () async {
      final result = await client.requestOtp(
        const RequestOtpDto(email: 'ana@2go.app'),
      );

      expect(method, 'POST');
      expect(path, '/auth/otp/request');
      expect(body, {'email': 'ana@2go.app'});
      expect(result['accessToken'], 'access-token');
    });

    test('POST /auth/otp/verify parses unwrapped token envelope data', () async {
      final tokens = await client.verifyOtp(
        const VerifyOtpDto(email: 'ana@2go.app', code: '123456'),
      );

      expect(path, '/auth/otp/verify');
      expect(body, {'email': 'ana@2go.app', 'code': '123456'});
      expect(tokens.accessToken, 'access-token');
      expect(tokens.refreshToken, 'refresh-token');
      expect(tokens.user?.email, 'ana@2go.app');
    });

    test('POST /auth/refresh parses tokens from unwrapped data', () async {
      final tokens = await client.refresh(
        const RefreshTokenDto(refreshToken: 'refresh-token'),
      );

      expect(path, '/auth/refresh');
      expect(body, {'refreshToken': 'refresh-token'});
      expect(tokens.accessToken, 'access-token');
    });

    test('POST /auth/login parses tokens', () async {
      final tokens = await client.login(
        const LoginDto(email: 'ana@2go.app', password: 'secret'),
      );

      expect(path, '/auth/login');
      expect(tokens.refreshToken, 'refresh-token');
    });

    test('POST /auth/logout hits path', () async {
      await client.logout(const RefreshTokenDto(refreshToken: 'refresh-token'));
      expect(path, '/auth/logout');
      expect(method, 'POST');
    });

    test('POST /auth/logout-all hits path', () async {
      await client.logoutAll();
      expect(path, '/auth/logout-all');
    });

    test('propagates DioException on OTP verify failure', () async {
      final failDio = Dio(BaseOptions(baseUrl: 'https://core.test'));
      failDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.badResponse,
                response: Response(
                  requestOptions: options,
                  statusCode: 400,
                  data: {
                    'success': false,
                    'code': 'AUTH_OTP_INVALID',
                    'message': 'Código incorreto',
                    'timestamp': '2026-11-20T00:00:00.000Z',
                  },
                ),
              ),
            );
          },
        ),
      );

      final failClient = AuthApiClient(failDio);
      expect(
        () => failClient.verifyOtp(
          const VerifyOtpDto(email: 'ana@2go.app', code: '000000'),
        ),
        throwsA(isA<DioException>()),
      );
    });

    test('AuthTokensResponseDto.fromJson reads unwrapped Core data', () {
      final dto = AuthTokensResponseDto.fromJson(_unwrappedTokens());
      expect(dto.accessToken, 'access-token');
      expect(dto.user?.fullName, 'Ana Silva');
    });
  });
}

Map<String, dynamic> _unwrappedTokens() => {
      'accessToken': 'access-token',
      'refreshToken': 'refresh-token',
      'user': {
        'id': 'usr_1',
        'email': 'ana@2go.app',
        'fullName': 'Ana Silva',
        'role': 'USER',
        'emailConfirmed': true,
      },
    };
