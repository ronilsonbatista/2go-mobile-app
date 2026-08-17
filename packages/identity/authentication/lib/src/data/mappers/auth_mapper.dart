import 'package:app_roteiros_api/app_roteiros_api.dart';
import 'package:twogo_security/twogo_security.dart';
import '../../domain/entities/auth_tokens_entity.dart';
import '../../domain/entities/user_entity.dart';

class AuthMapper {
  static AuthTokensEntity toTokensEntity(AuthTokensResponseDto dto) {
    return AuthTokensEntity(
      accessToken: dto.accessToken,
      refreshToken: dto.refreshToken,
    );
  }

  static AuthTokens toSecurityTokens(AuthTokensResponseDto dto) {
    return AuthTokens(
      accessToken: dto.accessToken,
      refreshToken: dto.refreshToken,
    );
  }

  static UserEntity? toUserEntity(UserDto? dto) {
    if (dto == null) return null;
    return UserEntity(
      id: dto.id,
      email: dto.email,
      fullName: dto.fullName,
      role: dto.role,
      emailConfirmed: dto.emailConfirmed,
    );
  }
}
