class SignupDto {
  final String email;
  final String fullName;
  final String password;

  const SignupDto({
    required this.email,
    required this.fullName,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {'email': email, 'fullName': fullName, 'password': password};
  }
}
