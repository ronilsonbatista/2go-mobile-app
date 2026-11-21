import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../contracts/token_storage.dart';
import '../models/auth_tokens.dart';
import 'secure_storage_options.dart';

class SecureTokenStorageImpl implements TokenStorage {
  static const String _accessTokenKey = '2go_secure_access_token';
  static const String _refreshTokenKey = '2go_secure_refresh_token';

  final FlutterSecureStorage _storage;

  /// In-process fallback when Keychain rejects writes (Simulator -34018 /
  /// missing keychain-access-groups under unsigned Debug builds).
  /// Keeps Bearer auth usable for the current session even if Keychain is down.
  AuthTokens? _memoryFallback;

  SecureTokenStorageImpl({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: TwogoSecureStorageOptions.android,
            iOptions: TwogoSecureStorageOptions.ios,
          );

  @override
  Future<void> saveTokens(AuthTokens tokens) async {
    try {
      await _storage.write(key: _accessTokenKey, value: tokens.accessToken);
      await _storage.write(key: _refreshTokenKey, value: tokens.refreshToken);
      _memoryFallback = null;
    } on PlatformException {
      // errSecMissingEntitlement (-34018) on unsigned Simulator builds.
      _memoryFallback = tokens;
    }
  }

  @override
  Future<AuthTokens?> readTokens() async {
    try {
      final access = await _storage.read(key: _accessTokenKey);
      final refresh = await _storage.read(key: _refreshTokenKey);

      if (access != null &&
          access.isNotEmpty &&
          refresh != null &&
          refresh.isNotEmpty) {
        return AuthTokens(accessToken: access, refreshToken: refresh);
      }
    } on PlatformException {
      // Fall through to in-memory session cache.
    }

    final fallback = _memoryFallback;
    if (fallback == null ||
        fallback.accessToken.isEmpty ||
        fallback.refreshToken.isEmpty) {
      return null;
    }
    return fallback;
  }

  @override
  Future<void> clearTokens() async {
    _memoryFallback = null;
    try {
      await _storage.delete(key: _accessTokenKey);
      await _storage.delete(key: _refreshTokenKey);
    } on PlatformException {
      // Best-effort clear — never block bootstrap/logout on keychain entitlement gaps.
    }
  }
}
