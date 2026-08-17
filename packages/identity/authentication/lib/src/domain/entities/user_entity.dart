class UserEntity {
  final String id;
  final String email;
  final String fullName;
  final String? photoUrl;
  final String role;
  final bool emailConfirmed;
  final DateTime? blockedAt;
  final DateTime? archivedAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.fullName,
    this.photoUrl,
    this.role = 'USER',
    this.emailConfirmed = false,
    this.blockedAt,
    this.archivedAt,
  });

  bool get isBlocked => blockedAt != null;
  bool get isArchived => archivedAt != null;
  bool get isAdmin => role.toUpperCase() == 'ADMIN';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          fullName == other.fullName &&
          photoUrl == other.photoUrl &&
          role == other.role;

  @override
  int get hashCode =>
      id.hashCode ^
      email.hashCode ^
      fullName.hashCode ^
      photoUrl.hashCode ^
      role.hashCode;
}
