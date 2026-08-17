import '../entities/auth_tokens_entity.dart';
import '../repositories/auth_repository.dart';

/// Domain UseCase for verifying an email OTP code and retrieving access/refresh tokens.
class VerifyOtpUseCase {
  const VerifyOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthTokensEntity> call({
    required String email,
    required String code,
    String? purpose,
  }) async {
    final sanitizedEmail = email.trim().toLowerCase();
    final sanitizedCode = code.trim();
    return _repository.verifyOtp(
      email: sanitizedEmail,
      code: sanitizedCode,
      purpose: purpose,
    );
  }
}
