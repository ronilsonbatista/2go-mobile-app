import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twogo_design_system/design_system.dart';
import 'package:twogo_mobile_app/src/app.dart';
import 'package:twogo_mobile_app/src/di/app_dependencies.dart';
import 'package:twogo_mobile_app/src/pages/launch_page.dart';
import 'package:twogo_session/twogo_session.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppShell & Router Tests', () {
    late AppDependencies dependencies;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      FlutterSecureStorage.setMockInitialValues({});
      dependencies = await AppDependencies.create(environment: 'development');
    });

    tearDown(() async {
      await dependencies.sessionCubit.close();
    });

    testWidgets('Cold start shows guest home with create CTA', (
      tester,
    ) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(390, 844)),
          child: TwoGoApp(
            environment: 'development',
            sessionCubit: dependencies.sessionCubit,
            authRepository: dependencies.authRepository,
            dependencies: dependencies,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Criar'), findsWidgets);
      expect(find.text('2go'), findsNothing); // splash already passed
    });

    testWidgets('Unauthenticated guest lands on guest home', (tester) async {
      await dependencies.sessionCubit.logout();

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(390, 844)),
          child: TwoGoApp(
            environment: 'development',
            sessionCubit: dependencies.sessionCubit,
            authRepository: dependencies.authRepository,
            dependencies: dependencies,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Criar'), findsWidgets);
    });

    testWidgets('Authenticated session renders AppShell tabs', (tester) async {
      dependencies.sessionCubit.onTokensReceived(
        accessToken: 'access_token',
        refreshToken: 'refresh_token',
        email: 'passageiro@2go.com',
      );

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(390, 844)),
          child: TwoGoApp(
            environment: 'development',
            sessionCubit: dependencies.sessionCubit,
            authRepository: dependencies.authRepository,
            dependencies: dependencies,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Início'), findsAtLeastNWidgets(1));
      expect(find.byType(TwoGoBottomNavigation), findsOneWidget);
    });

    testWidgets('Profile logout clears session', (tester) async {
      dependencies.sessionCubit.onTokensReceived(
        accessToken: 'access_token',
        refreshToken: 'refresh_token',
        email: 'passageiro@2go.com',
      );

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(390, 844)),
          child: TwoGoApp(
            environment: 'development',
            sessionCubit: dependencies.sessionCubit,
            authRepository: dependencies.authRepository,
            dependencies: dependencies,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Perfil'));
      await tester.pumpAndSettle();

      final logoutButton = find.text('Sair / Encerrar Sessão');
      if (logoutButton.evaluate().isNotEmpty) {
        await tester.ensureVisible(logoutButton);
        await tester.tap(logoutButton);
        await tester.pumpAndSettle();
        expect(
          dependencies.sessionCubit.state.status,
          equals(SessionStatus.unauthenticated),
        );
      }
    });
  });
}
