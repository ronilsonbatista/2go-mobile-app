import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:twogo_authentication/twogo_authentication.dart';
import 'package:twogo_session/twogo_session.dart';

import '../pages/home_page.dart';
import '../pages/launch_page.dart';
import '../pages/notifications_page.dart';
import '../pages/profile_page.dart';
import '../pages/trips_page.dart';
import '../shell/app_shell.dart';

class AppRouter {
  static GoRouter createRouter({
    required SessionCubit sessionCubit,
    required AuthRepository authRepository,
  }) {
    return GoRouter(
      initialLocation: _getInitialLocation(sessionCubit.state.status),
      refreshListenable: _GoRouterRefreshStream(sessionCubit.stream),
      redirect: (context, state) {
        final sessionStatus = sessionCubit.state.status;
        final location = state.matchedLocation;

        if (sessionStatus == SessionStatus.restoring ||
            sessionStatus == SessionStatus.unknown) {
          if (location != '/launch') {
            return '/launch';
          }
          return null;
        }

        final isAuthenticated = sessionStatus == SessionStatus.authenticated;
        final isAuthRoute = location.startsWith('/auth');

        if (!isAuthenticated && !isAuthRoute) {
          return '/auth';
        }

        if (isAuthenticated &&
            (isAuthRoute || location == '/launch' || location == '/')) {
          return '/app/home';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/launch',
          builder: (context, state) => const LaunchPage(),
        ),
        GoRoute(
          path: '/auth',
          builder: (context, state) {
            return BlocProvider<AuthenticationBloc>(
              create: (context) => AuthenticationBloc(
                requestOtpUseCase: RequestOtpUseCase(authRepository),
                verifyOtpUseCase: VerifyOtpUseCase(authRepository),
              ),
              child: BlocListener<AuthenticationBloc, AuthenticationState>(
                listenWhen: (previous, current) =>
                    previous.step != current.step &&
                    current.step == AuthenticationStep.authenticated &&
                    current.tokens != null,
                listener: (context, authState) {
                  if (authState.tokens != null) {
                    sessionCubit.onTokensReceived(
                      accessToken: authState.tokens!.accessToken,
                      refreshToken: authState.tokens!.refreshToken,
                      email: authState.email,
                    );
                  }
                },
                child: const AuthenticationPage(),
              ),
            );
          },
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return AppShell(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/app/home',
                  builder: (context, state) => const HomePage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/app/trips',
                  builder: (context, state) => const TripsPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/app/notifications',
                  builder: (context, state) => const NotificationsPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/app/profile',
                  builder: (context, state) => const ProfilePage(),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static String _getInitialLocation(SessionStatus status) {
    switch (status) {
      case SessionStatus.restoring:
      case SessionStatus.unknown:
        return '/launch';
      case SessionStatus.authenticated:
        return '/app/home';
      case SessionStatus.unauthenticated:
      case SessionStatus.expired:
        return '/auth';
    }
  }
}

class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
