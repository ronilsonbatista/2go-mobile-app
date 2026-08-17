import '../../domain/entities/auth_tokens_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/login_dto.dart';
import '../models/signup_dto.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  UserEntity? _currentUser;
  AuthTokensEntity? _currentTokens;

  AuthRepositoryImpl({required AuthRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<UserEntity> signup({
    required String email,
    required String fullName,
    required String password,
  }) async {
    final response = await _remoteDataSource.signup(
      SignupDto(email: email, fullName: fullName, password: password),
    );

    final user = UserEntity(
      id: response['userId'] as String? ?? 'u_new',
      email: email,
      fullName: fullName,
      role: 'USER',
    );
    _currentUser = user;
    return user;
  }

  @override
  Future<AuthTokensEntity> login({
    required String email,
    required String password,
  }) async {
    final dto = await _remoteDataSource.login(
      LoginDto(email: email, password: password),
    );
    final tokens = dto.toEntity();
    _currentTokens = tokens;
    _currentUser = UserEntity(
      id: 'u49a21b3-5e18-4931-8544-a68394848a68',
      email: email,
      fullName: 'João da Silva',
      role: 'USER',
    );
    return tokens;
  }

  @override
  Future<AuthTokensEntity> refreshTokens(String refreshToken) async {
    final dto = await _remoteDataSource.refreshTokens(refreshToken);
    final tokens = dto.toEntity();
    _currentTokens = tokens;
    return tokens;
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
    _currentTokens = null;
  }

  AuthTokensEntity? get currentTokens => _currentTokens;
}
