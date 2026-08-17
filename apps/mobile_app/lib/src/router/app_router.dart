import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:twogo_authentication/twogo_authentication.dart';
import 'package:twogo_session/twogo_session.dart';

import '../pages/authenticated_placeholder_page.dart';

class AppRouter {
  static GoRouter createRouter({
    required SessionCubit sessionCubit,
    required AuthRepository authRepository,
  }) {
    return GoRouter(
      initialLocation: sessionCubit.state.status == SessionStatus.authenticated
          ? '/home'
          : '/auth',
      refreshListenable: _GoRouterRefreshStream(sessionCubit.stream),
      redirect: (context, state) {
        final sessionState = sessionCubit.state;
        final isAuthenticated =
            sessionState.status == SessionStatus.authenticated;
        final isAuthRoute = state.matchedLocation == '/auth';

        if (!isAuthenticated && !isAuthRoute) {
          return '/auth';
        }

        if (isAuthenticated && isAuthRoute) {
          return '/home';
        }

        return null;
      },
      routes: [
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
        GoRoute(
          path: '/home',
          builder: (context, state) {
            return const AuthenticatedPlaceholderPage();
          },
        ),
      ],
    );
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
