import '../models/auth_tokens.dart';

abstract interface class TokenStorage {
  Future<void> saveTokens(AuthTokens tokens);
  Future<AuthTokens?> readTokens();
  Future<void> clearTokens();
}
