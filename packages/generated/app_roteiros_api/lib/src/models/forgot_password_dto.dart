class ForgotPasswordDto {
  final String email;

  const ForgotPasswordDto({required this.email});

  Map<String, dynamic> toJson() {
    return {'email': email};
  }
}
