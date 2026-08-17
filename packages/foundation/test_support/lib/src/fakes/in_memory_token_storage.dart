import 'package:twogo_security/twogo_security.dart';

class InMemoryTokenStorage implements TokenStorage {
  AuthTokens? _tokens;

  InMemoryTokenStorage([AuthTokens? initialTokens]) : _tokens = initialTokens;

  @override
  Future<void> saveTokens(AuthTokens tokens) async {
    _tokens = tokens;
  }

  @override
  Future<AuthTokens?> readTokens() async {
    return _tokens;
  }

  @override
  Future<void> clearTokens() async {
    _tokens = null;
  }
}
