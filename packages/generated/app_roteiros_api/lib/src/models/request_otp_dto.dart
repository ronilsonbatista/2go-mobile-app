class RequestOtpDto {
  final String email;

  /// Optional; omitted from JSON when null so body is `{ "email": "..." }`.
  final String? purpose;

  const RequestOtpDto({required this.email, this.purpose});

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      if (purpose != null) 'purpose': purpose,
    };
  }
}
