import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_authentication/twogo_authentication.dart';
import 'package:twogo_mobile_app/src/app.dart';
import 'package:twogo_security/twogo_security.dart';
import 'package:twogo_session/twogo_session.dart';

class MemoryTokenStorage implements TokenStorage {
  AuthTokens? _tokens;

  @override
  Future<void> clearTokens() async {
    _tokens = null;
  }

  @override
  Future<AuthTokens?> readTokens() async => _tokens;

  @override
  Future<void> saveTokens(AuthTokens tokens) async {
    _tokens = tokens;
  }
}

class FakeAuthRepository implements AuthRepository {
  @override
  Future<void> requestOtp({required String email, String? purpose}) async {}

  @override
  Future<AuthTokensEntity> verifyOtp({
    required String email,
    required String code,
    String? purpose,
  }) async =>
      const AuthTokensEntity(accessToken: 'access', refreshToken: 'refresh');

  @override
  Future<UserEntity> signup({
    required String email,
    required String fullName,
    required String password,
  }) async =>
      const UserEntity(id: '1', email: 'test@example.com', fullName: 'Test');

  @override
  Future<AuthTokensEntity> login({
    required String email,
    required String password,
  }) async =>
      const AuthTokensEntity(accessToken: 'access', refreshToken: 'refresh');

  @override
  Future<AuthTokensEntity> refreshTokens(String refreshToken) async =>
      const AuthTokensEntity(
        accessToken: 'new_access',
        refreshToken: 'new_refresh',
      );

  @override
  Future<UserEntity?> getCurrentUser() async => null;

  @override
  Future<void> logout() async {}

  @override
  Future<void> logoutAll() async {}

  @override
  Future<void> forgotPassword({required String email}) async {}

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {}
}

void main() {
  testWidgets('Renders 2GO main app widget', (WidgetTester tester) async {
    final tokenStorage = MemoryTokenStorage();
    final sessionCubit = SessionCubit(tokenStorage: tokenStorage);
    final authRepository = FakeAuthRepository();

    await tester.pumpWidget(
      TwoGoApp(
        environment: 'development',
        sessionCubit: sessionCubit,
        authRepository: authRepository,
      ),
    );

    expect(find.text('Entre ou cadastre-se\npara continuar'), findsOneWidget);
  });
}
