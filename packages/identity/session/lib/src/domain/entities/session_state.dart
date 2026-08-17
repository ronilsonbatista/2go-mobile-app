import 'package:twogo_security/twogo_security.dart';

enum SessionStatus {
  unknown,
  restoring,
  authenticated,
  unauthenticated,
  expired,
}

class SessionState {
  final SessionStatus status;
  final AuthTokens? tokens;
  final String? userId;

  const SessionState({required this.status, this.tokens, this.userId});

  factory SessionState.unknown() =>
      const SessionState(status: SessionStatus.unknown);
  factory SessionState.restoring() =>
      const SessionState(status: SessionStatus.restoring);
  factory SessionState.authenticated(AuthTokens tokens, [String? userId]) =>
      SessionState(
        status: SessionStatus.authenticated,
        tokens: tokens,
        userId: userId,
      );
  factory SessionState.unauthenticated() =>
      const SessionState(status: SessionStatus.unauthenticated);
  factory SessionState.expired() =>
      const SessionState(status: SessionStatus.expired);

  bool get isAuthenticated => status == SessionStatus.authenticated;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          tokens == other.tokens &&
          userId == other.userId;

  @override
  int get hashCode => status.hashCode ^ tokens.hashCode ^ userId.hashCode;
}
