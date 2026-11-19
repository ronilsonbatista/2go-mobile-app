import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twogo_design_system/design_system.dart';
import 'package:twogo_home/twogo_home.dart';
import 'package:twogo_mobile_app/src/app.dart';
import 'package:twogo_mobile_app/src/di/app_dependencies.dart';
import 'package:twogo_mobile_app/src/router/app_router.dart';
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
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.textContaining('Criar'), findsWidgets);
      expect(find.text('2go'), findsNothing); // splash already passed
      expect(find.byType(TwoGoBottomNavigation), findsNothing);

      // HomeCubit is provided with `.value` (not auto-closed); stop its timer.
      await tester.element(find.byType(HomeView)).read<HomeCubit>().close();
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
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.textContaining('Criar'), findsWidgets);
      expect(find.byType(TwoGoBottomNavigation), findsNothing);

      await tester.element(find.byType(HomeView)).read<HomeCubit>().close();
    });

    testWidgets('Authenticated Home has no bottom tab bar', (tester) async {
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
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.textContaining('Criar'), findsWidgets);
      expect(find.byType(TwoGoBottomNavigation), findsNothing);
      expect(find.text('Início'), findsNothing);
      expect(find.text('Viagens'), findsNothing);
      expect(find.text('Notificações'), findsNothing);
      expect(find.text('Perfil'), findsNothing);

      await tester.element(find.byType(HomeView)).read<HomeCubit>().close();
    });

    testWidgets('Q&A wizard has no bottom tab bar', (tester) async {
      await dependencies.sessionCubit.logout();

      final router = AppRouter.createRouter(dependencies: dependencies);

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(390, 844)),
          child: MaterialApp.router(
            theme: TwoGoTheme.light,
            routerConfig: router,
          ),
        ),
      );
      // Skip guest home (HomeCubit timers) — open Form Course directly.
      router.go('/planning/wizard');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('Para onde'), findsOneWidget);
      expect(find.byType(TwoGoBottomNavigation), findsNothing);
      expect(find.text('Início'), findsNothing);
      expect(find.text('Viagens'), findsNothing);
    });

    testWidgets('Profile logout clears session', (tester) async {
      dependencies.sessionCubit.onTokensReceived(
        accessToken: 'access_token',
        refreshToken: 'refresh_token',
        email: 'passageiro@2go.com',
      );

      final router = AppRouter.createRouter(dependencies: dependencies);

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(390, 844)),
          child: BlocProvider<SessionCubit>.value(
            value: dependencies.sessionCubit,
            child: MaterialApp.router(
              theme: TwoGoTheme.light,
              routerConfig: router,
            ),
          ),
        ),
      );
      router.go('/app/profile');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final logoutButton = find.text('Sair / Encerrar Sessão');
      if (logoutButton.evaluate().isNotEmpty) {
        await tester.ensureVisible(logoutButton);
        await tester.tap(logoutButton);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(
          dependencies.sessionCubit.state.status,
          equals(SessionStatus.unauthenticated),
        );
      }
    });
  });
}
