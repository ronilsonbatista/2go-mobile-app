import 'user_dto.dart';

class AuthTokensResponseDto {
  final String accessToken;
  final String refreshToken;
  final UserDto? user;

  const AuthTokensResponseDto({
    required this.accessToken,
    required this.refreshToken,
    this.user,
  });

  factory AuthTokensResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthTokensResponseDto(
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      user: json['user'] != null
          ? UserDto.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'user': user?.toJson(),
    };
  }
}
