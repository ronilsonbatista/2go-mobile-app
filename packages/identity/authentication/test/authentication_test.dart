import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_authentication/authentication.dart';

void main() {
  group('Authentication Package Tests (app-roteiros-core contracts)', () {
    late MockAuthDataSource mockDataSource;
    late AuthRepositoryImpl authRepository;
    late AuthCubit authCubit;

    setUp(() {
      mockDataSource = MockAuthDataSource();
      authRepository = AuthRepositoryImpl(remoteDataSource: mockDataSource);
      authCubit = AuthCubit(authRepository: authRepository);
    });

    tearDown(() {
      authCubit.dispose();
    });

    test('signup creates user and enables login', () async {
      final user = await authRepository.signup(
        email: 'novo@2go.com',
        fullName: 'Novo Viajante',
        password: 'Senha123Secure!',
      );

      expect(user.email, 'novo@2go.com');
      expect(user.fullName, 'Novo Viajante');
      expect(user.isAdmin, isFalse);
    });

    test('login with valid credentials returns tokens and user', () async {
      await authCubit.login('passageiro@2go.com', 'SenhaSegura123!');

      expect(authCubit.value.status, AuthStatus.authenticated);
      expect(authCubit.value.tokens, isNotNull);
      expect(authCubit.value.tokens!.accessToken, contains('mock_access_jwt_'));
      expect(authCubit.value.user!.email, 'passageiro@2go.com');
    });

    test('login with invalid credentials sets error status', () async {
      await authCubit.login('passageiro@2go.com', 'SenhaIncorreta');

      expect(authCubit.value.status, AuthStatus.error);
      expect(authCubit.value.errorMessage, 'Credenciais inválidas');
    });

    test('refreshTokens rotates token pair', () async {
      final tokens = await authRepository.refreshTokens(
        'mock_refresh_jwt_u123_456',
      );

      expect(tokens.accessToken, contains('mock_access_jwt_refreshed_'));
      expect(tokens.refreshToken, contains('mock_refresh_jwt_rotated_'));
    });

    test('logout clears user state', () async {
      await authCubit.login('passageiro@2go.com', 'SenhaSegura123!');
      expect(authCubit.value.status, AuthStatus.authenticated);

      await authCubit.logout();
      expect(authCubit.value.status, AuthStatus.unauthenticated);
      expect(authCubit.value.user, isNull);
    });
  });
}
