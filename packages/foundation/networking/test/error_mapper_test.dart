import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_core/twogo_core.dart';
import 'package:twogo_networking/twogo_networking.dart';

void main() {
  group('ErrorMapper Tests for NestJS ApiErrorResponse', () {
    test('maps AUTH_OTP_INVALID error code to InvalidOtpFailure', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/auth/otp/verify'),
        response: Response(
          requestOptions: RequestOptions(path: '/auth/otp/verify'),
          statusCode: 400,
          data: {
            'success': false,
            'code': 'AUTH_OTP_INVALID',
            'message': 'Código incorreto',
          },
        ),
      );

      final failure = ErrorMapper.mapDioError(dioError);
      expect(failure, isA<InvalidOtpFailure>());
      expect(failure.message, 'Código incorreto');
    });

    test('maps AUTH_OTP_EXPIRED to ExpiredOtpFailure', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/auth/otp/verify'),
        response: Response(
          requestOptions: RequestOptions(path: '/auth/otp/verify'),
          statusCode: 400,
          data: {
            'success': false,
            'code': 'AUTH_OTP_EXPIRED',
            'message': 'Código expirado',
          },
        ),
      );

      final failure = ErrorMapper.mapDioError(dioError);
      expect(failure, isA<ExpiredOtpFailure>());
    });

    test('maps AUTH_OTP_TOO_MANY_ATTEMPTS to TooManyOtpAttemptsFailure', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/auth/otp/verify'),
        response: Response(
          requestOptions: RequestOptions(path: '/auth/otp/verify'),
          statusCode: 429,
          data: {
            'success': false,
            'code': 'AUTH_OTP_TOO_MANY_ATTEMPTS',
            'message': 'Limite de tentativas excedido',
          },
        ),
      );

      final failure = ErrorMapper.mapDioError(dioError);
      expect(failure, isA<TooManyOtpAttemptsFailure>());
    });

    test('maps connection timeout to NetworkFailure', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/trips'),
        type: DioExceptionType.connectionTimeout,
      );

      final failure = ErrorMapper.mapDioError(dioError);
      expect(failure, isA<NetworkFailure>());
    });
  });
}
