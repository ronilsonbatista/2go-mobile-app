import 'package:dio/dio.dart';
import 'package:twogo_core/twogo_core.dart';

class ErrorMapper {
  static AppFailure mapDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.connectionError) {
      return const NetworkFailure(
        message:
            'Sem conexão com a internet ou servidor indisponível. Verifique sua rede.',
      );
    }

    final response = error.response;
    if (response == null || response.data == null) {
      return UnknownFailure(
        message: error.message ?? 'Erro inesperado de comunicação HTTP.',
        statusCode: response?.statusCode ?? 500,
      );
    }

    final data = response.data;
    if (data is Map<String, dynamic>) {
      final code = data['code'] as String?;
      final rawMessage = data['message'];
      final message = rawMessage is List
          ? rawMessage.join(', ')
          : rawMessage?.toString() ?? 'Erro na requisição.';

      if (code != null && code.isNotEmpty) {
        return _mapErrorCode(code, message, response.statusCode ?? 400);
      }

      return _mapStatusCode(response.statusCode ?? 400, message);
    }

    return UnknownFailure(
      message: 'Resposta inesperada do servidor.',
      statusCode: response.statusCode ?? 500,
    );
  }

  static AppFailure _mapErrorCode(String code, String message, int statusCode) {
    switch (code) {
      case 'AUTH_OTP_INVALID':
        return InvalidOtpFailure(message: message);
      case 'AUTH_OTP_EXPIRED':
        return ExpiredOtpFailure(message: message);
      case 'AUTH_OTP_TOO_MANY_ATTEMPTS':
        return TooManyOtpAttemptsFailure(message: message);
      case 'AUTH_OTP_RATE_LIMITED':
        return OtpRateLimitedFailure(message: message);
      case 'AUTH_SESSION_EXPIRED':
        return SessionExpiredFailure(message: message);
      case 'AUTH_REFRESH_TOKEN_INVALID':
        return InvalidRefreshTokenFailure(message: message);
      case 'AUTH_CREDENTIALS_INVALID':
        return InvalidCredentialsFailure(message: message);
      case 'AUTH_USER_BLOCKED':
        return UserBlockedFailure(message: message);
      case 'AUTH_USER_ARCHIVED':
        return UserArchivedFailure(message: message);
      case 'AUTH_USER_EXISTS':
        return UserExistsFailure(message: message);
      case 'AUTH_USER_NOT_FOUND':
        return UserNotFoundFailure(message: message);
      default:
        return UnknownFailure(
          code: code,
          message: message,
          statusCode: statusCode,
        );
    }
  }

  static AppFailure _mapStatusCode(int statusCode, String message) {
    switch (statusCode) {
      case 401:
        return SessionExpiredFailure(message: message);
      case 403:
        return AccessDeniedFailure(message: message);
      case 404:
        return NotFoundFailure(message: message);
      default:
        return UnknownFailure(message: message, statusCode: statusCode);
    }
  }
}
