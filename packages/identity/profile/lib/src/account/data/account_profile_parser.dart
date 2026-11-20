import '../domain/account_profile.dart';

/// Parses Core `GET /users/me` into [AccountProfile].
///
/// Prefers nested `user` (`id`/`userId`, `displayName`/`fullName`, `email`,
/// `photoUrl`) per Core Users contract.
class AccountProfileParser {
  const AccountProfileParser();

  AccountProfile parse(dynamic payload, {String? fallbackEmail}) {
    final user = _extractUser(payload);
    final id = _string(user['id']) ??
        _string(user['userId']) ??
        '';
    final email = _string(user['email']) ?? fallbackEmail ?? '';
    final displayName = _string(user['displayName']) ??
        _string(user['fullName']) ??
        _string(user['name']);
    final photoUrl = _string(user['photoUrl']);

    return AccountProfile(
      id: id,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
    );
  }

  Map<String, dynamic> _extractUser(dynamic payload) {
    if (payload == null) return const {};
    if (payload is! Map) return const {};
    final map = Map<String, dynamic>.from(payload);

    if (map.containsKey('data')) {
      final data = map['data'];
      if (data is Map) {
        return _userFromData(Map<String, dynamic>.from(data));
      }
    }
    return _userFromData(map);
  }

  Map<String, dynamic> _userFromData(Map<String, dynamic> data) {
    final nested = data['user'];
    if (nested is Map) {
      return Map<String, dynamic>.from(nested);
    }
    return data;
  }

  String? _string(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }
}
