import '../entities/auth_tokens_entity.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<void> requestOtp({required String email, String? purpose});

  Future<AuthTokensEntity> verifyOtp({
    required String email,
    required String code,
    String? purpose,
  });

  Future<UserEntity> signup({
    required String email,
    required String fullName,
    required String password,
  });

  Future<AuthTokensEntity> login({
    required String email,
    required String password,
  });

  Future<AuthTokensEntity> refreshTokens(String refreshToken);

  Future<UserEntity?> getCurrentUser();

  Future<void> logout();

  Future<void> logoutAll();

  Future<void> forgotPassword({required String email});

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });
}
