import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twogo_security/twogo_security.dart';
import '../../domain/entities/session_state.dart';

class SessionCubit extends Cubit<SessionState> {
  final TokenStorage _tokenStorage;

  SessionCubit({required TokenStorage tokenStorage})
    : _tokenStorage = tokenStorage,
      super(SessionState.unknown());

  Future<void> restoreSession() async {
    emit(SessionState.restoring());
    try {
      final tokens = await _tokenStorage.readTokens();
      if (tokens != null && tokens.accessToken.isNotEmpty) {
        emit(SessionState.authenticated(tokens));
      } else {
        emit(SessionState.unauthenticated());
      }
    } catch (e) {
      await _tokenStorage.clearTokens();
      emit(SessionState.unauthenticated());
    }
  }

  Future<void> onTokensReceived({
    required String accessToken,
    required String refreshToken,
    String? email,
  }) async {
    final tokens = AuthTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    await _tokenStorage.saveTokens(tokens);
    emit(SessionState.authenticated(tokens, email));
  }

  void onAuthenticated(AuthTokens tokens, [String? userId]) {
    emit(SessionState.authenticated(tokens, userId));
  }

  Future<void> logout() async {
    await onLogout();
  }

  Future<void> onLogout() async {
    await _tokenStorage.clearTokens();
    emit(SessionState.unauthenticated());
  }

  Future<void> onSessionExpired() async {
    await _tokenStorage.clearTokens();
    emit(SessionState.expired());
  }
}
