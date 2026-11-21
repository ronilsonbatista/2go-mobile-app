import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_security/twogo_security.dart';

/// Fake that always throws Keychain -34018 (errSecMissingEntitlement).
class _ThrowingSecureStorage extends FlutterSecureStorage {
  _ThrowingSecureStorage() : super();

  static final PlatformException missingEntitlement = PlatformException(
    code: 'Unexpected security result code',
    message: 'Code: -34018, Message: A required entitlement isn\'t present.',
    details: -34018,
  );

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    throw missingEntitlement;
  }

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    throw missingEntitlement;
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    throw missingEntitlement;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SecureTokenStorageImpl Keychain -34018 fallback', () {
    late SecureTokenStorageImpl storage;

    setUp(() {
      storage = SecureTokenStorageImpl(storage: _ThrowingSecureStorage());
    });

    test('save + read keeps tokens in memory when Keychain rejects', () async {
      const tokens = AuthTokens(
        accessToken: 'access-secret',
        refreshToken: 'refresh-secret',
      );
      await storage.saveTokens(tokens);

      expect(await storage.readTokens(), equals(tokens));
    });

    test('clearTokens drops memory fallback', () async {
      await storage.saveTokens(
        const AuthTokens(accessToken: 'a', refreshToken: 'r'),
      );
      await storage.clearTokens();

      expect(await storage.readTokens(), isNull);
    });
  });
}
