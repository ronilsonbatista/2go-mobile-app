class VerifyOtpDto {
  final String email;
  final String code;

  /// Optional; omitted from JSON when null so body is `{ "email", "code" }`.
  final String? purpose;

  const VerifyOtpDto({
    required this.email,
    required this.code,
    this.purpose,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'code': code,
      if (purpose != null) 'purpose': purpose,
    };
  }
}
