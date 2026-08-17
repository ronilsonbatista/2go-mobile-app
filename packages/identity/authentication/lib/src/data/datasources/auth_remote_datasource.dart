import '../models/auth_tokens_dto.dart';
import '../models/login_dto.dart';
import '../models/signup_dto.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> signup(SignupDto dto);
  Future<AuthTokensDto> login(LoginDto dto);
  Future<AuthTokensDto> refreshTokens(String refreshToken);
}
