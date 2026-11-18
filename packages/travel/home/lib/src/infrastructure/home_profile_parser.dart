import '../domain/models/home_profile.dart';

/// Parses Core `GET /users/me` profile fields for the Home avatar chip.
///
/// Accepts the raw envelope or unwrapped `data`. Prefers nested `user`
/// (`id`, `displayName`, `photoUrl`) per Core Home contracts.
class HomeProfileParser {
  const HomeProfileParser();

  HomeProfile parse(
    dynamic payload, {
    String? fallbackDisplayName,
  }) {
    final user = _extractUser(payload);
    final displayName = _string(user['displayName']) ??
        _string(user['fullName']) ??
        _string(user['name']) ??
        fallbackDisplayName ??
        'Viajante';

    // Explicit null / missing / empty photoUrl → initials (Home-11).
    final photoUrl = _string(user['photoUrl']);

    return HomeProfile.authenticated(
      displayName: displayName,
      photoUrl: photoUrl,
    );
  }

  Map<String, dynamic> _extractUser(dynamic payload) {
    if (payload == null) return const {};

    if (payload is Map) {
      final map = Map<String, dynamic>.from(payload);

      // Raw envelope → data.user or data itself.
      if (map.containsKey('data')) {
        final data = map['data'];
        if (data is Map) {
          return _userFromData(Map<String, dynamic>.from(data));
        }
      }

      return _userFromData(map);
    }

    return const {};
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
