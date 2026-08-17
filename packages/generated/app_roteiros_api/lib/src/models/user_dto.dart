class UserDto {
  final String id;
  final String email;
  final String fullName;
  final String role;
  final bool emailConfirmed;

  const UserDto({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.emailConfirmed,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] as String? ?? json['userId'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      role: json['role'] as String? ?? 'USER',
      emailConfirmed: json['emailConfirmed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'role': role,
      'emailConfirmed': emailConfirmed,
    };
  }
}
