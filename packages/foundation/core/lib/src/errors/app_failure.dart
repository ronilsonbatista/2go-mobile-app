abstract class AppFailure implements Exception {
  final String message;
  final String? code;
  final int? statusCode;

  const AppFailure({required this.message, this.code, this.statusCode});

  @override
  String toString() => message;
}

class NetworkFailure extends AppFailure {
  const NetworkFailure({required super.message, super.code, super.statusCode});
}

class InvalidOtpFailure extends AppFailure {
  const InvalidOtpFailure({
    required super.message,
    super.code = 'AUTH_OTP_INVALID',
    super.statusCode = 400,
  });
}

class ExpiredOtpFailure extends AppFailure {
  const ExpiredOtpFailure({
    required super.message,
    super.code = 'AUTH_OTP_EXPIRED',
    super.statusCode = 400,
  });
}

class TooManyOtpAttemptsFailure extends AppFailure {
  const TooManyOtpAttemptsFailure({
    required super.message,
    super.code = 'AUTH_OTP_TOO_MANY_ATTEMPTS',
    super.statusCode = 429,
  });
}

class OtpRateLimitedFailure extends AppFailure {
  const OtpRateLimitedFailure({
    required super.message,
    super.code = 'AUTH_OTP_RATE_LIMITED',
    super.statusCode = 429,
  });
}

class SessionExpiredFailure extends AppFailure {
  const SessionExpiredFailure({
    required super.message,
    super.code = 'AUTH_SESSION_EXPIRED',
    super.statusCode = 401,
  });
}

class InvalidRefreshTokenFailure extends AppFailure {
  const InvalidRefreshTokenFailure({
    required super.message,
    super.code = 'AUTH_REFRESH_TOKEN_INVALID',
    super.statusCode = 401,
  });
}

class InvalidCredentialsFailure extends AppFailure {
  const InvalidCredentialsFailure({
    required super.message,
    super.code = 'AUTH_CREDENTIALS_INVALID',
    super.statusCode = 401,
  });
}

class UserBlockedFailure extends AppFailure {
  const UserBlockedFailure({
    required super.message,
    super.code = 'AUTH_USER_BLOCKED',
    super.statusCode = 403,
  });
}

class UserArchivedFailure extends AppFailure {
  const UserArchivedFailure({
    required super.message,
    super.code = 'AUTH_USER_ARCHIVED',
    super.statusCode = 403,
  });
}

class UserExistsFailure extends AppFailure {
  const UserExistsFailure({
    required super.message,
    super.code = 'AUTH_USER_EXISTS',
    super.statusCode = 409,
  });
}

class UserNotFoundFailure extends AppFailure {
  const UserNotFoundFailure({
    required super.message,
    super.code = 'AUTH_USER_NOT_FOUND',
    super.statusCode = 404,
  });
}

class AccessDeniedFailure extends AppFailure {
  const AccessDeniedFailure({
    required super.message,
    super.code = 'ACCESS_DENIED',
    super.statusCode = 403,
  });
}

class NotFoundFailure extends AppFailure {
  const NotFoundFailure({
    required super.message,
    super.code = 'NOT_FOUND',
    super.statusCode = 404,
  });
}

class UnknownFailure extends AppFailure {
  const UnknownFailure({
    required super.message,
    super.code,
    super.statusCode = 500,
  });
}
