import 'package:equatable/equatable.dart';

/// Account fields from Core `GET /users/me` (+ local-only phone/cpf until Core
/// exposes them).
class AccountProfile extends Equatable {
  const AccountProfile({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.phone,
    this.cpf,
  });

  factory AccountProfile.guest() => const AccountProfile(
        id: '',
        email: '',
      );

  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;

  /// Local-only — Core User has no phone field today.
  final String? phone;

  /// Local-only — Core User has no cpf field today.
  final String? cpf;

  bool get hasPhoto => photoUrl != null && photoUrl!.trim().isNotEmpty;

  String get initials {
    final fromName = _initialsFrom(displayName);
    if (fromName != null) return fromName;
    final fromEmail = _initialsFrom(email);
    return fromEmail ?? '2G';
  }

  AccountProfile copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    bool clearPhotoUrl = false,
    String? phone,
    String? cpf,
  }) {
    return AccountProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: clearPhotoUrl ? null : (photoUrl ?? this.photoUrl),
      phone: phone ?? this.phone,
      cpf: cpf ?? this.cpf,
    );
  }

  static String? _initialsFrom(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    var value = raw.trim();
    if (value.contains('@')) {
      value = value.split('@').first;
    }
    final spaced = value.split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (spaced.length >= 2) {
      final list = spaced.toList();
      return '${list[0][0]}${list[1][0]}'.toUpperCase();
    }
    final dotted = value.split(RegExp(r'[._-]+')).where((p) => p.isNotEmpty);
    if (dotted.length >= 2) {
      final list = dotted.toList();
      return '${list[0][0]}${list[1][0]}'.toUpperCase();
    }
    if (value.isEmpty) return null;
    return value.substring(0, value.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  List<Object?> get props => [id, email, displayName, photoUrl, phone, cpf];
}
