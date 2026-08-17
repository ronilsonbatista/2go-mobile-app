import 'package:flutter/foundation.dart';
import 'package:twogo_security/twogo_security.dart';
import '../../domain/entities/session_state.dart';

class SessionCubit extends ValueNotifier<SessionState> {
  final TokenStorage _tokenStorage;

  SessionCubit({required TokenStorage tokenStorage})
    : _tokenStorage = tokenStorage,
      super(SessionState.unknown());

  Future<void> restoreSession() async {
    value = SessionState.restoring();
    try {
      final tokens = await _tokenStorage.readTokens();
      if (tokens != null && tokens.accessToken.isNotEmpty) {
        value = SessionState.authenticated(tokens);
      } else {
        value = SessionState.unauthenticated();
      }
    } catch (e) {
      await _tokenStorage.clearTokens();
      value = SessionState.unauthenticated();
    }
  }

  void onAuthenticated(AuthTokens tokens, [String? userId]) {
    value = SessionState.authenticated(tokens, userId);
  }

  Future<void> onLogout() async {
    await _tokenStorage.clearTokens();
    value = SessionState.unauthenticated();
  }

  Future<void> onSessionExpired() async {
    await _tokenStorage.clearTokens();
    value = SessionState.expired();
  }
}
