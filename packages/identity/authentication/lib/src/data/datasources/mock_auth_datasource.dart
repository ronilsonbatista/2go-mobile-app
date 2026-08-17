import '../models/auth_tokens_dto.dart';
import '../models/login_dto.dart';
import '../models/signup_dto.dart';
import 'auth_remote_datasource.dart';

class MockAuthDataSource implements AuthRemoteDataSource {
  final Map<String, Map<String, String>> _users = {
    'passageiro@2go.com': {
      'id': 'u49a21b3-5e18-4931-8544-a68394848a68',
      'email': 'passageiro@2go.com',
      'fullName': 'João da Silva',
      'password': 'SenhaSegura123!',
      'role': 'USER',
    },
  };

  @override
  Future<Map<String, dynamic>> signup(SignupDto dto) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (_users.containsKey(dto.email.toLowerCase())) {
      throw Exception('Email já está em uso');
    }

    final newId = 'u_${DateTime.now().millisecondsSinceEpoch}';
    _users[dto.email.toLowerCase()] = {
      'id': newId,
      'email': dto.email.toLowerCase(),
      'fullName': dto.fullName,
      'password': dto.password,
      'role': 'USER',
    };

    return {'message': 'Usuário registrado com sucesso', 'userId': newId};
  }

  @override
  Future<AuthTokensDto> login(LoginDto dto) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final userData = _users[dto.email.toLowerCase()];

    if (userData == null || userData['password'] != dto.password) {
      throw Exception('Credenciais inválidas');
    }

    return AuthTokensDto(
      accessToken:
          'mock_access_jwt_${userData['id']}_${DateTime.now().millisecondsSinceEpoch}',
      refreshToken:
          'mock_refresh_jwt_${userData['id']}_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  @override
  Future<AuthTokensDto> refreshTokens(String refreshToken) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    if (!refreshToken.startsWith('mock_refresh_jwt_')) {
      throw Exception('Refresh token inválido ou expirado');
    }

    return AuthTokensDto(
      accessToken:
          'mock_access_jwt_refreshed_${DateTime.now().millisecondsSinceEpoch}',
      refreshToken:
          'mock_refresh_jwt_rotated_${DateTime.now().millisecondsSinceEpoch}',
    );
  }
}
