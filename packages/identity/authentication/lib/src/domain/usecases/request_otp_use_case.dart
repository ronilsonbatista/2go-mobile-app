import '../repositories/auth_repository.dart';

/// Domain UseCase for requesting an email OTP verification code.
class RequestOtpUseCase {
  const RequestOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call({required String email, String? purpose}) async {
    final sanitized = email.trim().toLowerCase();
    return _repository.requestOtp(email: sanitized, purpose: purpose);
  }
}
