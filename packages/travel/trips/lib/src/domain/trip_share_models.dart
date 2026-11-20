/// Trip share / invite models aligned with Core Participants + welcome APIs.
library;

/// Guest membership role from Core (`ParticipantRole.VIEWER`).
const String kTripGuestRole = 'VIEWER';

class TripParticipant {
  final String id;
  final String tripId;
  final String email;
  final String role;
  final bool accepted;
  final String? inviteToken;
  final String? invitedById;
  final String? acceptedById;
  final DateTime? welcomeSeenAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Local-only display name from the invite form (Core stores email only).
  final String? displayName;

  const TripParticipant({
    required this.id,
    required this.tripId,
    required this.email,
    this.role = kTripGuestRole,
    this.accepted = false,
    this.inviteToken,
    this.invitedById,
    this.acceptedById,
    this.welcomeSeenAt,
    this.createdAt,
    this.updatedAt,
    this.displayName,
  });

  bool get isGuest => role.toUpperCase() == kTripGuestRole;

  String get initials {
    final source = (displayName?.trim().isNotEmpty == true)
        ? displayName!.trim()
        : email.trim();
    final parts = source
        .split(RegExp(r'[\s@._-]+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final p = parts.first;
      return (p.length >= 2 ? p.substring(0, 2) : p).toUpperCase();
    }
    return ('${parts[0][0]}${parts[1][0]}').toUpperCase();
  }

  String get label {
    final name = displayName?.trim();
    if (name != null && name.isNotEmpty) return name;
    final local = email.split('@').first.trim();
    return local.isEmpty ? email : local;
  }

  factory TripParticipant.fromJson(Map<String, dynamic> json) {
    return TripParticipant(
      id: json['id']?.toString() ?? '',
      tripId: json['tripId']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? kTripGuestRole,
      accepted: json['accepted'] == true,
      inviteToken: json['inviteToken']?.toString(),
      invitedById: json['invitedById']?.toString(),
      acceptedById: json['acceptedById']?.toString(),
      welcomeSeenAt: _parseDate(json['welcomeSeenAt']),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
      displayName: json['displayName']?.toString() ?? json['name']?.toString(),
    );
  }

  TripParticipant copyWith({
    String? displayName,
    bool? accepted,
    DateTime? welcomeSeenAt,
  }) {
    return TripParticipant(
      id: id,
      tripId: tripId,
      email: email,
      role: role,
      accepted: accepted ?? this.accepted,
      inviteToken: inviteToken,
      invitedById: invitedById,
      acceptedById: acceptedById,
      welcomeSeenAt: welcomeSeenAt ?? this.welcomeSeenAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      displayName: displayName ?? this.displayName,
    );
  }
}

class TripInviteResult {
  final String message;
  final String participantId;

  const TripInviteResult({
    required this.message,
    required this.participantId,
  });

  factory TripInviteResult.fromJson(Map<String, dynamic> json) {
    return TripInviteResult(
      message: json['message']?.toString() ?? 'Convite enviado com sucesso',
      participantId: json['participantId']?.toString() ?? '',
    );
  }
}

class TripAcceptInviteResult {
  final String message;
  final String tripId;

  const TripAcceptInviteResult({
    required this.message,
    required this.tripId,
  });

  factory TripAcceptInviteResult.fromJson(Map<String, dynamic> json) {
    return TripAcceptInviteResult(
      message: json['message']?.toString() ?? 'Convite aceito com sucesso',
      tripId: json['tripId']?.toString() ?? '',
    );
  }
}

class TripWelcomeTripSummary {
  final String id;
  final String title;
  final String destination;
  final String? coverImage;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? inviterName;

  const TripWelcomeTripSummary({
    required this.id,
    required this.title,
    required this.destination,
    this.coverImage,
    this.startDate,
    this.endDate,
    this.inviterName,
  });

  factory TripWelcomeTripSummary.fromJson(Map<String, dynamic> json) {
    return TripWelcomeTripSummary(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      destination: json['destination']?.toString() ??
          json['title']?.toString() ??
          '',
      coverImage: json['coverImage']?.toString(),
      startDate: _parseDate(json['startDate']),
      endDate: _parseDate(json['endDate']),
      inviterName: json['inviterName']?.toString() ??
          json['ownerName']?.toString() ??
          json['invitedByName']?.toString(),
    );
  }
}

class TripWelcomeItem {
  final String tripId;
  final String participantId;
  final String role;
  final bool isGuest;
  final DateTime? welcomeSeenAt;
  final TripWelcomeTripSummary trip;

  const TripWelcomeItem({
    required this.tripId,
    required this.participantId,
    this.role = kTripGuestRole,
    this.isGuest = true,
    this.welcomeSeenAt,
    required this.trip,
  });

  factory TripWelcomeItem.fromJson(Map<String, dynamic> json) {
    final tripJson = json['trip'];
    return TripWelcomeItem(
      tripId: json['tripId']?.toString() ?? '',
      participantId: json['participantId']?.toString() ?? '',
      role: json['role']?.toString() ?? kTripGuestRole,
      isGuest: json['isGuest'] == true ||
          (json['role']?.toString().toUpperCase() == kTripGuestRole),
      welcomeSeenAt: _parseDate(json['welcomeSeenAt']),
      trip: tripJson is Map
          ? TripWelcomeTripSummary.fromJson(
              Map<String, dynamic>.from(tripJson),
            )
          : TripWelcomeTripSummary(
              id: json['tripId']?.toString() ?? '',
              title: '',
              destination: '',
            ),
    );
  }
}

class TripWelcomeSeenResult {
  final String tripId;
  final String participantId;
  final bool isGuest;
  final DateTime? welcomeSeenAt;

  const TripWelcomeSeenResult({
    required this.tripId,
    required this.participantId,
    this.isGuest = true,
    this.welcomeSeenAt,
  });

  factory TripWelcomeSeenResult.fromJson(Map<String, dynamic> json) {
    return TripWelcomeSeenResult(
      tripId: json['tripId']?.toString() ?? '',
      participantId: json['participantId']?.toString() ?? '',
      isGuest: json['isGuest'] != false,
      welcomeSeenAt: _parseDate(json['welcomeSeenAt']),
    );
  }
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString());
}
