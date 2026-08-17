class RequestOtpDto {
  final String email;
  final String? purpose;

  const RequestOtpDto({required this.email, this.purpose = 'LOGIN'});

  Map<String, dynamic> toJson() {
    return {'email': email, if (purpose != null) 'purpose': purpose};
  }
}
