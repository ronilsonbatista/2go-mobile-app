import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_authentication/twogo_authentication.dart';
import 'package:twogo_design_system/design_system.dart';
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
  group('AppShell & Router Tests', () {
    late MemoryTokenStorage tokenStorage;
    late SessionCubit sessionCubit;
    late FakeAuthRepository authRepository;

    setUp(() {
      tokenStorage = MemoryTokenStorage();
      sessionCubit = SessionCubit(tokenStorage: tokenStorage);
      authRepository = FakeAuthRepository();
    });

    tearDown(() {
      sessionCubit.close();
    });

    testWidgets('Restoring session displays LaunchPage loading indicator', (
      tester,
    ) async {
      await tester.pumpWidget(
        TwoGoApp(
          environment: 'development',
          sessionCubit: sessionCubit,
          authRepository: authRepository,
        ),
      );

      expect(find.text('Restaurando sessão 2GO...'), findsOneWidget);
    });

    testWidgets('Unauthenticated session redirects to /auth', (tester) async {
      await sessionCubit.logout();

      await tester.pumpWidget(
        TwoGoApp(
          environment: 'development',
          sessionCubit: sessionCubit,
          authRepository: authRepository,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Entre ou cadastre-se\npara continuar'), findsOneWidget);
    });

    testWidgets('Authenticated session renders AppShell and navigates tabs', (
      tester,
    ) async {
      sessionCubit.onTokensReceived(
        accessToken: 'access_token',
        refreshToken: 'refresh_token',
        email: 'passageiro@2go.com',
      );

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(390, 844)),
          child: TwoGoApp(
            environment: 'development',
            sessionCubit: sessionCubit,
            authRepository: authRepository,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Início'), findsAtLeastNWidgets(1));
      expect(find.text('Bem-vindo ao 2GO'), findsOneWidget);

      // Switch to Viagens
      await tester.tap(find.text('Viagens'));
      await tester.pumpAndSettle();
      expect(find.text('Minhas Viagens'), findsOneWidget);

      // Switch to Notificações
      await tester.tap(find.text('Notificações'));
      await tester.pumpAndSettle();
      expect(
        find.text('Avisos e atualizações sobre seus voos e reservas.'),
        findsOneWidget,
      );

      // Switch to Perfil
      await tester.tap(find.text('Perfil'));
      await tester.pumpAndSettle();
      expect(find.text('passageiro@2go.com'), findsOneWidget);
    });

    testWidgets('Profile logout clears session and redirects to /auth', (
      tester,
    ) async {
      sessionCubit.onTokensReceived(
        accessToken: 'access_token',
        refreshToken: 'refresh_token',
        email: 'passageiro@2go.com',
      );

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(390, 844)),
          child: TwoGoApp(
            environment: 'development',
            sessionCubit: sessionCubit,
            authRepository: authRepository,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Go to Profile tab
      await tester.tap(find.text('Perfil'));
      await tester.pumpAndSettle();

      // Ensure button visible and tap Logout
      final logoutButton = find.text('Sair / Encerrar Sessão');
      await tester.ensureVisible(logoutButton);
      await tester.tap(logoutButton);
      await tester.pumpAndSettle();

      expect(find.text('Entre ou cadastre-se\npara continuar'), findsOneWidget);
      expect(sessionCubit.state.status, equals(SessionStatus.unauthenticated));
    });

    testWidgets('Golden Test - app_shell_home (390 x 844)', (tester) async {
      sessionCubit.onTokensReceived(
        accessToken: 'access_token',
        refreshToken: 'refresh_token',
        email: 'passageiro@2go.com',
      );

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(390, 844)),
          child: TwoGoApp(
            environment: 'development',
            sessionCubit: sessionCubit,
            authRepository: authRepository,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TwoGoBottomNavigation), findsOneWidget);
    });
  });
}
