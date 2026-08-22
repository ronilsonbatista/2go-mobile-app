import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:twogo_authentication/twogo_authentication.dart';
import 'package:twogo_checkout/twogo_checkout.dart';
import 'package:twogo_payments/twogo_payments.dart';
import 'package:twogo_session/twogo_session.dart';
import 'package:twogo_planning/twogo_planning.dart';

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
    PostAuthIntentStorage? intentStorage,
    PaymentsRepository? paymentsRepository,
  }) {
    final effectiveIntentStorage =
        intentStorage ?? PersistentPostAuthIntentStorage();
    final effectivePaymentsRepo = paymentsRepository ??
        PaymentsRepositoryImpl(
          remoteDataSource: MockPaymentsDataSource(),
        );

    return GoRouter(
      initialLocation: _getInitialLocation(sessionCubit.state.status),
      refreshListenable: _GoRouterRefreshStream(sessionCubit.stream),
      redirect: (context, state) async {
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

        if (isAuthenticated) {
          final intent = await effectiveIntentStorage.readIntent();
          if (intent != null &&
              intent.type == PostAuthIntentType.resumeCheckout &&
              intent.tripId != null &&
              intent.tripId!.isNotEmpty) {
            if (location != '/checkout') {
              return '/checkout?tripId=${intent.tripId}';
            }
            return null;
          }

          if (isAuthRoute || location == '/launch' || location == '/') {
            return '/app/home';
          }
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
        GoRoute(
          path: '/checkout',
          builder: (context, state) {
            final tripId = state.uri.queryParameters['tripId'] ?? '';
            return CheckoutPage(
              tripId: tripId,
              paymentsRepository: effectivePaymentsRepo,
              intentStorage: effectiveIntentStorage,
              onPaymentRequested: (tId, method, coupon) {
                // Handed off in L1 to payment requested handler (L2B will perform POST purchases/checkout)
                context.go('/app/home');
              },
              onCardReadyForPayment: (cardState) {
                // Handed off in L2A (L2B will perform POST purchases/checkout)
                context.go('/app/home');
              },
              onCancelled: () {
                context.go('/app/home');
              },
              onAlreadyEntitledCompleted: () {
                context.go('/app/home');
              },
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
