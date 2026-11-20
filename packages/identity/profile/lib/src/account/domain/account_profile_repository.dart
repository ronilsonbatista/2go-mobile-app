import 'dart:typed_data';

import 'account_profile.dart';

abstract class AccountProfileRepository {
  /// Core `GET /users/me`.
  Future<AccountProfile> fetchMe({String? fallbackEmail});

  /// Core `POST /media/upload/avatar` (multipart field `file`).
  Future<String> uploadAvatar({
    required List<int> bytes,
    required String filename,
    String? contentType,
  });
}

/// No-op local repository used when Dio is unavailable (tests / guest).
class LocalAccountProfileRepository implements AccountProfileRepository {
  LocalAccountProfileRepository({AccountProfile? seed})
      : _profile = seed ?? AccountProfile.guest();

  AccountProfile _profile;

  @override
  Future<AccountProfile> fetchMe({String? fallbackEmail}) async {
    if (_profile.email.isEmpty && fallbackEmail != null) {
      return AccountProfile(
        id: _profile.id,
        email: fallbackEmail,
        displayName: _profile.displayName,
        photoUrl: _profile.photoUrl,
        phone: _profile.phone,
        cpf: _profile.cpf,
      );
    }
    return _profile;
  }

  @override
  Future<String> uploadAvatar({
    required List<int> bytes,
    required String filename,
    String? contentType,
  }) async {
    // Local stub — no Core call.
    final url = 'local://avatar/$filename';
    _profile = _profile.copyWith(photoUrl: url);
    return url;
  }

  void seed(AccountProfile profile) => _profile = profile;
}

/// Typed alias so callers can pass [Uint8List] without a second import.
typedef AvatarBytes = Uint8List;
