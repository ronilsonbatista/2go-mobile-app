import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../contracts/token_storage.dart';
import '../models/auth_tokens.dart';

class SecureTokenStorageImpl implements TokenStorage {
  static const String _accessTokenKey = '2go_secure_access_token';
  static const String _refreshTokenKey = '2go_secure_refresh_token';

  final FlutterSecureStorage _storage;

  SecureTokenStorageImpl({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock,
            ),
          );

  @override
  Future<void> saveTokens(AuthTokens tokens) async {
    await _storage.write(key: _accessTokenKey, value: tokens.accessToken);
    await _storage.write(key: _refreshTokenKey, value: tokens.refreshToken);
  }

  @override
  Future<AuthTokens?> readTokens() async {
    final access = await _storage.read(key: _accessTokenKey);
    final refresh = await _storage.read(key: _refreshTokenKey);

    if (access == null ||
        access.isEmpty ||
        refresh == null ||
        refresh.isEmpty) {
      return null;
    }
    return AuthTokens(accessToken: access, refreshToken: refresh);
  }

  @override
  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}
