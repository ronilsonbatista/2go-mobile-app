import 'package:flutter/foundation.dart';
import '../../domain/entities/auth_tokens_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final UserEntity? user;
  final AuthTokensEntity? tokens;
  final String? errorMessage;

  const AuthState({
    required this.status,
    this.user,
    this.tokens,
    this.errorMessage,
  });

  factory AuthState.initial() => const AuthState(status: AuthStatus.initial);
  factory AuthState.loading() => const AuthState(status: AuthStatus.loading);
  factory AuthState.authenticated(UserEntity user, AuthTokensEntity tokens) =>
      AuthState(status: AuthStatus.authenticated, user: user, tokens: tokens);
  factory AuthState.unauthenticated() =>
      const AuthState(status: AuthStatus.unauthenticated);
  factory AuthState.error(String message) =>
      AuthState(status: AuthStatus.error, errorMessage: message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          user == other.user &&
          tokens == other.tokens &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode =>
      status.hashCode ^ user.hashCode ^ tokens.hashCode ^ errorMessage.hashCode;
}

class AuthCubit extends ValueNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(AuthState.initial());

  Future<void> checkAuthStatus() async {
    value = AuthState.loading();
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        value = AuthState.authenticated(
          user,
          const AuthTokensEntity(
            accessToken: 'mock_access',
            refreshToken: 'mock_refresh',
          ),
        );
      } else {
        value = AuthState.unauthenticated();
      }
    } catch (e) {
      value = AuthState.error(e.toString());
    }
  }

  Future<void> login(String email, String password) async {
    value = AuthState.loading();
    try {
      final tokens = await _authRepository.login(
        email: email,
        password: password,
      );
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        value = AuthState.authenticated(user, tokens);
      } else {
        value = AuthState.unauthenticated();
      }
    } catch (e) {
      value = AuthState.error(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> signup(String email, String fullName, String password) async {
    value = AuthState.loading();
    try {
      await _authRepository.signup(
        email: email,
        fullName: fullName,
        password: password,
      );
      await login(email, password);
    } catch (e) {
      value = AuthState.error(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> logout() async {
    value = AuthState.loading();
    await _authRepository.logout();
    value = AuthState.unauthenticated();
  }
}
