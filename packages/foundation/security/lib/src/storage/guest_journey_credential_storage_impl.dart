import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../contracts/guest_journey_credential_storage.dart';

class GuestJourneyCredentialStorageImpl
    implements GuestJourneyCredentialStorage {
  static const String _keyPrefix = '2go_guest_journey_token_';

  final FlutterSecureStorage _storage;

  GuestJourneyCredentialStorageImpl({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock,
            ),
          );

  @override
  Future<void> saveGuestToken({
    required String journeyId,
    required String guestToken,
  }) async {
    await _storage.write(key: '$_keyPrefix$journeyId', value: guestToken);
  }

  @override
  Future<String?> readGuestToken(String journeyId) async {
    final token = await _storage.read(key: '$_keyPrefix$journeyId');
    if (token == null || token.isEmpty) {
      return null;
    }
    return token;
  }

  @override
  Future<void> clearGuestToken(String journeyId) async {
    await _storage.delete(key: '$_keyPrefix$journeyId');
  }

  @override
  Future<void> clearAllGuestTokens() async {
    final allKeys = await _storage.readAll();
    for (final key in allKeys.keys) {
      if (key.startsWith(_keyPrefix)) {
        await _storage.delete(key: key);
      }
    }
  }
}
