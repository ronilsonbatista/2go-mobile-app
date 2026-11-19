import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Shared FlutterSecureStorage platform options for 2GO credentials.
///
/// iOS uses the app default Keychain access group (no explicit [IOSOptions.groupId])
/// so device builds with a Team ID prefix keep working. Keychain Sharing is enabled
/// via `Runner/Runner.entitlements`; Simulator Debug builds that skip Xcode CodeSign
/// must re-sign with that file or Keychain returns -34018.
abstract final class TwogoSecureStorageOptions {
  static const AndroidOptions android = AndroidOptions(
    encryptedSharedPreferences: true,
  );

  static const IOSOptions ios = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
  );
}
