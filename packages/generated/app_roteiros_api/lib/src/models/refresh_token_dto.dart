class RefreshTokenDto {
  final String refreshToken;

  const RefreshTokenDto({required this.refreshToken});

  Map<String, dynamic> toJson() {
    return {'refreshToken': refreshToken};
  }
}
