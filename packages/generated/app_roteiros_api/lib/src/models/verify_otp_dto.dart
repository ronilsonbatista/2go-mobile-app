class VerifyOtpDto {
  final String email;
  final String code;
  final String? purpose;

  const VerifyOtpDto({
    required this.email,
    required this.code,
    this.purpose = 'LOGIN',
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'code': code,
      if (purpose != null) 'purpose': purpose,
    };
  }
}
