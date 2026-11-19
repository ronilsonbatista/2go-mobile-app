import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_security/twogo_security.dart';

/// Fake that always throws Keychain -34018 (errSecMissingEntitlement).
class _ThrowingSecureStorage extends FlutterSecureStorage {
  _ThrowingSecureStorage() : super();

  static const PlatformException missingEntitlement = PlatformException(
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

  @override
  Future<Map<String, String>> readAll({
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

  group('GuestJourneyCredentialStorageImpl Keychain -34018 fallback', () {
    late GuestJourneyCredentialStorageImpl storage;

    setUp(() {
      storage = GuestJourneyCredentialStorageImpl(
        storage: _ThrowingSecureStorage(),
      );
    });

    test('save + read keeps guest token in memory when Keychain rejects', () async {
      await storage.saveGuestToken(
        journeyId: 'journey-1',
        guestToken: 'guest-secret',
      );

      expect(await storage.readGuestToken('journey-1'), 'guest-secret');
    });

    test('clearGuestToken drops memory fallback', () async {
      await storage.saveGuestToken(
        journeyId: 'journey-1',
        guestToken: 'guest-secret',
      );
      await storage.clearGuestToken('journey-1');

      expect(await storage.readGuestToken('journey-1'), isNull);
    });

    test('clearAllGuestTokens drops all memory fallbacks', () async {
      await storage.saveGuestToken(
        journeyId: 'journey-1',
        guestToken: 'a',
      );
      await storage.saveGuestToken(
        journeyId: 'journey-2',
        guestToken: 'b',
      );
      await storage.clearAllGuestTokens();

      expect(await storage.readGuestToken('journey-1'), isNull);
      expect(await storage.readGuestToken('journey-2'), isNull);
    });
  });

  group('TwogoSecureStorageOptions', () {
    test('exposes shared Android encrypted prefs + iOS first_unlock', () {
      expect(
        TwogoSecureStorageOptions.android.params['encryptedSharedPreferences'],
        'true',
      );
      expect(
        TwogoSecureStorageOptions.ios.params['accessibility'],
        'first_unlock',
      );
    });
  });
}
