import 'package:equatable/equatable.dart';

/// Profile chip data for the Home header (guest vs authenticated).
class HomeProfile extends Equatable {
  const HomeProfile({
    required this.isAuthenticated,
    this.displayName,
    this.photoUrl,
    this.photoAssetPath,
    this.initials,
  });

  factory HomeProfile.guest() => const HomeProfile(isAuthenticated: false);

  factory HomeProfile.authenticated({
    String? displayName,
    String? photoUrl,
    String? photoAssetPath,
    String? initials,
  }) {
    return HomeProfile(
      isAuthenticated: true,
      displayName: displayName,
      photoUrl: photoUrl,
      photoAssetPath: photoAssetPath,
      initials: initials ?? _initialsFrom(displayName),
    );
  }

  final bool isAuthenticated;
  final String? displayName;

  /// Remote customer photo when Core exposes it.
  final String? photoUrl;

  /// Optional local demo photo (layout QA only).
  final String? photoAssetPath;

  /// Fallback when authenticated but no photo (e.g. "GV").
  final String? initials;

  bool get hasPhoto =>
      (photoUrl != null && photoUrl!.isNotEmpty) ||
      (photoAssetPath != null && photoAssetPath!.isNotEmpty);

  static String? _initialsFrom(String? name) {
    if (name == null || name.trim().isEmpty) return null;
    var value = name.trim();
    if (value.contains('@')) {
      value = value.split('@').first;
    }

    final spaced = value.split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (spaced.length >= 2) {
      final list = spaced.toList();
      return '${list[0][0]}${list[1][0]}'.toUpperCase();
    }

    // Emails / usernames like "gustavo.vieira" → "GV"
    final dotted = value.split(RegExp(r'[._-]+')).where((p) => p.isNotEmpty);
    if (dotted.length >= 2) {
      final list = dotted.toList();
      return '${list[0][0]}${list[1][0]}'.toUpperCase();
    }

    if (value.isEmpty) return null;
    return value.substring(0, value.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  List<Object?> get props => [
    isAuthenticated,
    displayName,
    photoUrl,
    photoAssetPath,
    initials,
  ];
}
