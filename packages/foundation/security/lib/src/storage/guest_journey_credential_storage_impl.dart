import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../contracts/guest_journey_credential_storage.dart';
import 'secure_storage_options.dart';

class GuestJourneyCredentialStorageImpl
    implements GuestJourneyCredentialStorage {
  static const String _keyPrefix = '2go_guest_journey_token_';

  final FlutterSecureStorage _storage;

  /// In-process fallback when Keychain rejects writes (Simulator -34018 /
  /// missing keychain-access-groups entitlement under unsigned Debug builds).
  /// Keeps guest finalize usable for the current session even if Keychain is down.
  final Map<String, String> _memoryFallback = {};

  GuestJourneyCredentialStorageImpl({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: TwogoSecureStorageOptions.android,
            iOptions: TwogoSecureStorageOptions.ios,
          );

  String _storageKey(String journeyId) => '$_keyPrefix$journeyId';

  @override
  Future<void> saveGuestToken({
    required String journeyId,
    required String guestToken,
  }) async {
    final key = _storageKey(journeyId);
    try {
      await _storage.write(key: key, value: guestToken);
      _memoryFallback.remove(key);
    } on PlatformException {
      // errSecMissingEntitlement (-34018) on unsigned Simulator builds.
      _memoryFallback[key] = guestToken;
    }
  }

  @override
  Future<String?> readGuestToken(String journeyId) async {
    final key = _storageKey(journeyId);
    try {
      final token = await _storage.read(key: key);
      if (token != null && token.isNotEmpty) {
        return token;
      }
    } on PlatformException {
      // Fall through to in-memory session cache.
    }
    final fallback = _memoryFallback[key];
    if (fallback == null || fallback.isEmpty) {
      return null;
    }
    return fallback;
  }

  @override
  Future<void> clearGuestToken(String journeyId) async {
    final key = _storageKey(journeyId);
    _memoryFallback.remove(key);
    try {
      await _storage.delete(key: key);
    } on PlatformException {
      // Best-effort — memory cache already cleared.
    }
  }

  @override
  Future<void> clearAllGuestTokens() async {
    final memoryKeys = _memoryFallback.keys
        .where((key) => key.startsWith(_keyPrefix))
        .toList(growable: false);
    for (final key in memoryKeys) {
      _memoryFallback.remove(key);
    }

    try {
      final allKeys = await _storage.readAll();
      for (final key in allKeys.keys) {
        if (key.startsWith(_keyPrefix)) {
          await _storage.delete(key: key);
        }
      }
    } on PlatformException {
      // Best-effort clear when Keychain entitlement is missing.
    }
  }
}
