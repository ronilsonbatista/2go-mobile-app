import 'package:dio/dio.dart';
import 'package:twogo_core/twogo_core.dart';

/// Maps Dio / Nest error envelopes into typed [AppFailure]s for shared UI.
class ErrorMapper {
  static AppFailure mapDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.connectionError) {
      return const NetworkFailure();
    }

    final response = error.response;
    if (response == null || response.data == null) {
      // No response usually means offline / DNS / TLS — treat as connectivity.
      if (error.type == DioExceptionType.unknown &&
          error.error != null &&
          error.message?.toLowerCase().contains('socket') == true) {
        return const NetworkFailure();
      }
      return UnknownFailure(
        message: error.message ?? 'Erro inesperado de comunicação HTTP.',
        statusCode: response?.statusCode ?? 500,
      );
    }

    final data = response.data;
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final code = _asPlainString(map['code']);
      final statusCode = response.statusCode ?? 400;
      final messageList = _asMessageList(map['message']);
      final message = messageList.isNotEmpty
          ? messageList.join(', ')
          : 'Erro na requisição.';

      if (code != null && code.isNotEmpty) {
        return _mapErrorCode(
          code,
          message,
          statusCode,
          messageList: messageList,
          raw: map,
        );
      }

      return _mapStatusCode(
        statusCode,
        message,
        messageList: messageList,
        raw: map,
      );
    }

    return UnknownFailure(
      message: 'Resposta inesperada do servidor.',
      statusCode: response.statusCode ?? 500,
    );
  }

  /// Prefer this in repositories / use cases so Dio never reaches the UI.
  static Never throwMapped(DioException error) {
    throw mapDioError(error);
  }

  static AppFailure mapAny(Object error) {
    if (error is AppFailure) return error;
    if (error is DioException) return mapDioError(error);
    return UnknownFailure(message: error.toString());
  }

  static AppFailure _mapErrorCode(
    String code,
    String message,
    int statusCode, {
    List<String> messageList = const [],
    Map<String, dynamic> raw = const {},
  }) {
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
      case 'BAD_REQUEST':
        return _validationFailure(
          message: message,
          messageList: messageList,
          raw: raw,
          statusCode: statusCode,
          code: code,
        );
      default:
        if (statusCode == 400 || statusCode == 422) {
          return _validationFailure(
            message: message,
            messageList: messageList,
            raw: raw,
            statusCode: statusCode,
            code: code,
          );
        }
        return UnknownFailure(
          code: code,
          message: message,
          statusCode: statusCode,
        );
    }
  }

  static AppFailure _mapStatusCode(
    int statusCode,
    String message, {
    List<String> messageList = const [],
    Map<String, dynamic> raw = const {},
  }) {
    switch (statusCode) {
      case 400:
      case 422:
        return _validationFailure(
          message: message,
          messageList: messageList,
          raw: raw,
          statusCode: statusCode,
        );
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

  static ValidationFailure _validationFailure({
    required String message,
    required List<String> messageList,
    required Map<String, dynamic> raw,
    required int statusCode,
    String code = 'BAD_REQUEST',
  }) {
    final fieldErrors = <String, String>{
      ..._fieldErrorsFromObject(raw['errors']),
      ..._fieldErrorsFromMessages(messageList),
    };

    return ValidationFailure(
      message: message,
      fieldErrors: fieldErrors,
      messages: messageList.isEmpty ? [message] : messageList,
      code: code,
      statusCode: statusCode,
    );
  }

  static Map<String, String> _fieldErrorsFromObject(Object? errors) {
    if (errors is! Map) return const {};
    final out = <String, String>{};
    errors.forEach((key, value) {
      final field = key.toString();
      if (value is List && value.isNotEmpty) {
        out[field] = value.first.toString();
      } else if (value != null) {
        out[field] = value.toString();
      }
    });
    return out;
  }

  /// Parses Nest ValidationPipe strings like `email must be an email`
  /// or `destinations.0.order must not be less than 1`.
  static Map<String, String> _fieldErrorsFromMessages(List<String> messages) {
    final out = <String, String>{};
    final pathPattern = RegExp(r'^([A-Za-z_][\w]*(?:\.\d+)?(?:\.\w+)*)\s');
    for (final raw in messages) {
      final message = raw.trim();
      if (message.isEmpty) continue;
      final match = pathPattern.firstMatch(message);
      if (match == null) continue;
      final path = match.group(1)!;
      final root = path.split('.').first;
      out.putIfAbsent(root, () => _friendlyFieldMessage(message));
    }
    return out;
  }

  static String _friendlyFieldMessage(String technical) {
    final lower = technical.toLowerCase();
    if (lower.contains('email')) {
      return TwoGoCoreFieldMessages.invalid;
    }
    if (lower.contains('should not be empty') ||
        lower.contains('must be a string') ||
        lower.contains('is required')) {
      return TwoGoCoreFieldMessages.required;
    }
    return TwoGoCoreFieldMessages.invalid;
  }

  static String? _asPlainString(Object? value) {
    if (value == null) return null;
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    return value.toString();
  }

  static List<String> _asMessageList(Object? value) {
    if (value == null) return const [];
    if (value is List) {
      return value
          .map((e) => e?.toString().trim() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
    }
    final single = value.toString().trim();
    return single.isEmpty ? const [] : [single];
  }
}
