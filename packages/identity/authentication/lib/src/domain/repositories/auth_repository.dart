import '../entities/auth_tokens_entity.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
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
}
