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

    test('maps connection timeout to NetworkFailure with design copy', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/trips'),
        type: DioExceptionType.connectionTimeout,
      );

      final failure = ErrorMapper.mapDioError(dioError);
      expect(failure, isA<NetworkFailure>());
      expect(failure.message, NetworkFailure.defaultMessage);
      expect(failure.message, 'Sem conexão com a internet!');
    });

    test('maps connectionError to NetworkFailure', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/places/autocomplete'),
        type: DioExceptionType.connectionError,
      );

      final failure = ErrorMapper.mapDioError(dioError);
      expect(failure, isA<NetworkFailure>());
    });

    test('maps BAD_REQUEST message list to ValidationFailure field errors', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/auth/otp/request'),
        response: Response(
          requestOptions: RequestOptions(path: '/auth/otp/request'),
          statusCode: 400,
          data: {
            'success': false,
            'code': 'BAD_REQUEST',
            'message': [
              'email must be an email',
              'code must be longer than or equal to 6 characters',
            ],
          },
        ),
      );

      final failure = ErrorMapper.mapDioError(dioError);
      expect(failure, isA<ValidationFailure>());
      final validation = failure as ValidationFailure;
      expect(validation.fieldErrors.containsKey('email'), isTrue);
      expect(validation.fieldErrors.containsKey('code'), isTrue);
      expect(validation.errorFor('email'), TwoGoCoreFieldMessages.invalid);
    });

    test('maps Nest order Min(1) message into destinations field error', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/planning-sessions/x'),
        response: Response(
          requestOptions: RequestOptions(path: '/planning-sessions/x'),
          statusCode: 400,
          data: {
            'statusCode': 400,
            'message': ['destinations.0.order must not be less than 1'],
            'error': 'Bad Request',
          },
        ),
      );

      final failure = ErrorMapper.mapDioError(dioError);
      expect(failure, isA<ValidationFailure>());
      expect(
        (failure as ValidationFailure).fieldErrors.containsKey('destinations'),
        isTrue,
      );
    });
  });
}
