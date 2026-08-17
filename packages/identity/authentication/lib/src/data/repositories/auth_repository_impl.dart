import 'package:app_roteiros_api/app_roteiros_api.dart' as api;
import 'package:twogo_security/twogo_security.dart';
import '../../domain/entities/auth_tokens_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../mappers/auth_mapper.dart';
import '../models/login_dto.dart';
import '../models/signup_dto.dart';

class AuthRepositoryImpl implements AuthRepository {
  final api.AuthApiClient? _apiClient;
  final TokenStorage? _tokenStorage;
  final AuthRemoteDataSource? _remoteDataSource;

  UserEntity? _currentUser;
  AuthTokensEntity? _currentTokens;

  AuthRepositoryImpl({
    api.AuthApiClient? apiClient,
    TokenStorage? tokenStorage,
    AuthRemoteDataSource? remoteDataSource,
  }) : _apiClient = apiClient,
       _tokenStorage = tokenStorage,
       _remoteDataSource = remoteDataSource;

  @override
  Future<void> requestOtp({required String email, String? purpose}) async {
    if (_apiClient != null) {
      await _apiClient.requestOtp(
        api.RequestOtpDto(email: email, purpose: purpose),
      );
      return;
    }
  }

  @override
  Future<AuthTokensEntity> verifyOtp({
    required String email,
    required String code,
    String? purpose,
  }) async {
    if (_apiClient != null) {
      final response = await _apiClient.verifyOtp(
        api.VerifyOtpDto(email: email, code: code, purpose: purpose),
      );
      final tokensEntity = AuthMapper.toTokensEntity(response);
      _currentUser = AuthMapper.toUserEntity(response.user);
      _currentTokens = tokensEntity;

      if (_tokenStorage != null) {
        await _tokenStorage.saveTokens(AuthMapper.toSecurityTokens(response));
      }
      return tokensEntity;
    }

    final mockTokens = AuthTokensEntity(
      accessToken: 'mock_access_$email',
      refreshToken: 'mock_refresh_$email',
    );
    _currentUser = UserEntity(
      id: 'u_otp_$email',
      email: email,
      fullName: email.split('@')[0],
      emailConfirmed: true,
    );
    _currentTokens = mockTokens;
    return mockTokens;
  }

  @override
  Future<UserEntity> signup({
    required String email,
    required String fullName,
    required String password,
  }) async {
    if (_apiClient != null) {
      final response = await _apiClient.signup(
        api.SignupDto(email: email, fullName: fullName, password: password),
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

    if (_remoteDataSource != null) {
      final res = await _remoteDataSource.signup(
        SignupDto(email: email, fullName: fullName, password: password),
      );
      final user = UserEntity(
        id: res['userId'] as String? ?? 'u_new',
        email: email,
        fullName: fullName,
        role: 'USER',
      );
      _currentUser = user;
      return user;
    }

    final user = UserEntity(id: 'u_new', email: email, fullName: fullName);
    _currentUser = user;
    return user;
  }

  @override
  Future<AuthTokensEntity> login({
    required String email,
    required String password,
  }) async {
    if (_apiClient != null) {
      final response = await _apiClient.login(
        api.LoginDto(email: email, password: password),
      );
      final tokensEntity = AuthMapper.toTokensEntity(response);
      _currentTokens = tokensEntity;
      _currentUser =
          AuthMapper.toUserEntity(response.user) ??
          UserEntity(id: 'u_logged', email: email, fullName: 'Passageiro');

      if (_tokenStorage != null) {
        await _tokenStorage.saveTokens(AuthMapper.toSecurityTokens(response));
      }
      return tokensEntity;
    }

    if (_remoteDataSource != null) {
      final dto = await _remoteDataSource.login(
        LoginDto(email: email, password: password),
      );
      final tokens = dto.toEntity();
      _currentTokens = tokens;
      _currentUser = UserEntity(
        id: 'u_logged',
        email: email,
        fullName: 'Passageiro',
      );
      return tokens;
    }

    const tokens = AuthTokensEntity(
      accessToken: 'mock_acc',
      refreshToken: 'mock_ref',
    );
    _currentTokens = tokens;
    _currentUser = UserEntity(
      id: 'u_logged',
      email: email,
      fullName: 'Passageiro',
    );
    return tokens;
  }

  @override
  Future<AuthTokensEntity> refreshTokens(String refreshToken) async {
    if (_apiClient != null) {
      final response = await _apiClient.refresh(
        api.RefreshTokenDto(refreshToken: refreshToken),
      );
      final tokensEntity = AuthMapper.toTokensEntity(response);
      _currentTokens = tokensEntity;

      if (_tokenStorage != null) {
        await _tokenStorage.saveTokens(AuthMapper.toSecurityTokens(response));
      }
      return tokensEntity;
    }

    if (_remoteDataSource != null) {
      final dto = await _remoteDataSource.refreshTokens(refreshToken);
      final tokens = dto.toEntity();
      _currentTokens = tokens;
      return tokens;
    }

    const tokens = AuthTokensEntity(
      accessToken: 'mock_acc_refreshed',
      refreshToken: 'mock_ref_refreshed',
    );
    _currentTokens = tokens;
    return tokens;
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  Future<void> logout() async {
    if (_apiClient != null) {
      try {
        await _apiClient.logout();
      } catch (_) {}
    }
    if (_tokenStorage != null) {
      await _tokenStorage.clearTokens();
    }
    _currentUser = null;
    _currentTokens = null;
  }

  @override
  Future<void> logoutAll() async {
    if (_apiClient != null) {
      try {
        await _apiClient.logoutAll();
      } catch (_) {}
    }
    if (_tokenStorage != null) {
      await _tokenStorage.clearTokens();
    }
    _currentUser = null;
    _currentTokens = null;
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    if (_apiClient != null) {
      await _apiClient.forgotPassword(api.ForgotPasswordDto(email: email));
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    if (_apiClient != null) {
      await _apiClient.resetPassword(
        api.ResetPasswordDto(
          email: email,
          code: code,
          newPassword: newPassword,
        ),
      );
    }
  }

  AuthTokensEntity? get currentTokens => _currentTokens;
}
