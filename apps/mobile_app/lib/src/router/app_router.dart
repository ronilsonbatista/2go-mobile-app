import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:twogo_authentication/twogo_authentication.dart';
import 'package:twogo_checkout/twogo_checkout.dart';
import 'package:twogo_planning/twogo_planning.dart';
import 'package:twogo_session/twogo_session.dart';
import 'package:twogo_storage/twogo_storage.dart';

import '../di/app_dependencies.dart';
import '../pages/home_page.dart';
import '../pages/launch_page.dart';
import '../pages/notifications_page.dart';
import '../pages/profile_page.dart';
import '../pages/trips_page.dart';
import '../shell/app_shell.dart';

class AppRouter {
  static const _guestAllowedPrefixes = <String>[
    '/launch',
    '/debug',
    '/auth',
    '/app',
    '/planning',
  ];

  static GoRouter createRouter({required AppDependencies dependencies}) {
    final sessionCubit = dependencies.sessionCubit;
    final intentStorage = dependencies.intentStorage;

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
        final isGuestAllowed = _guestAllowedPrefixes.any(
          (prefix) => location == prefix || location.startsWith('$prefix/'),
        );

        // Guest-first: unauthenticated users may access home + planning + auth.
        if (!isAuthenticated && !isGuestAllowed) {
          return '/app/home';
        }

        if (isAuthenticated) {
          final storage = TwoGoStorage();
          final handoffTripId = await storage.getString(
            'active_paid_handoff_trip_id',
          );
          final handoffPurchaseId = await storage.getString(
            'active_paid_handoff_purchase_id',
          );
          if (handoffTripId != null && handoffTripId.isNotEmpty) {
            if (location != '/paid-handoff') {
              return '/paid-handoff?tripId=$handoffTripId&purchaseId=${handoffPurchaseId ?? ''}';
            }
            return null;
          }

          final intent = await intentStorage.readIntent();
          if (intent != null) {
            if (intent.type == PostAuthIntentType.claimGuestJourney &&
                intent.journeyId != null &&
                intent.journeyId!.isNotEmpty) {
              final claimPath = '/planning/claim';
              if (!location.startsWith(claimPath)) {
                final product = intent.productId ?? '';
                return '$claimPath?journeyId=${intent.journeyId}&productId=$product';
              }
              return null;
            }

            if (intent.type == PostAuthIntentType.resumeCheckout &&
                intent.tripId != null &&
                intent.tripId!.isNotEmpty) {
              if (location != '/checkout') {
                return '/checkout?tripId=${intent.tripId}';
              }
              return null;
            }
          }

          if (location == '/auth' || location == '/launch' || location == '/') {
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
        // Debug-only: hold Splash for visual certification without delaying prod cold-start.
        if (kDebugMode)
          GoRoute(
            path: '/debug/splash',
            builder: (context, state) => const LaunchPage(),
          ),
        GoRoute(
          path: '/auth',
          builder: (context, state) {
            return BlocProvider<AuthenticationBloc>(
              create: (context) => AuthenticationBloc(
                requestOtpUseCase: RequestOtpUseCase(
                  dependencies.authRepository,
                ),
                verifyOtpUseCase: VerifyOtpUseCase(
                  dependencies.authRepository,
                ),
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
          path: '/planning/wizard',
          builder: (context, state) {
            return PlanningWizardPage(
              bloc: dependencies.createPlanningWizardBloc(),
              searchPlacesUseCase: dependencies.searchPlacesUseCase,
              onExit: () => context.go('/app/home'),
              onReadyToGenerate: (journeyId) {
                context.go('/planning/generation/$journeyId');
              },
            );
          },
        ),
        GoRoute(
          path: '/planning/generation/:journeyId',
          builder: (context, state) {
            final journeyId = state.pathParameters['journeyId']!;
            return PlanningGenerationPage(
              journeyId: journeyId,
              bloc: dependencies.createPlanningGenerationBloc(),
              onPreviewReady: (id) {
                context.go('/planning/preview/$id');
              },
            );
          },
        ),
        GoRoute(
          path: '/planning/preview/:journeyId',
          builder: (context, state) {
            final journeyId = state.pathParameters['journeyId']!;
            return PlanningPreviewPage(
              journeyId: journeyId,
              bloc: dependencies.createPlanningPreviewBloc(),
              onUnlockRequested: (id, productId) async {
                await dependencies.intentStorage.saveIntent(
                  PostAuthIntent(
                    type: PostAuthIntentType.claimGuestJourney,
                    journeyId: id,
                    productId: productId,
                    createdAt: DateTime.now(),
                  ),
                );
                if (context.mounted) {
                  context.go('/auth');
                }
              },
            );
          },
        ),
        GoRoute(
          path: '/planning/claim',
          builder: (context, state) {
            final journeyId = state.uri.queryParameters['journeyId'] ?? '';
            final productId = state.uri.queryParameters['productId'];
            return PlanningClaimPage(
              journeyId: journeyId,
              productId: productId?.isEmpty == true ? null : productId,
              bloc: dependencies.createPlanningClaimBloc(),
              onClaimed: (tripId, nextAction) {
                context.go('/checkout?tripId=$tripId');
              },
            );
          },
        ),
        GoRoute(
          path: '/checkout',
          builder: (context, state) {
            final tripId = state.uri.queryParameters['tripId'] ?? '';
            return CheckoutPage(
              tripId: tripId,
              paymentsRepository: dependencies.paymentsRepository,
              intentStorage: intentStorage,
              storage: TwoGoStorage(),
              cardTokenizer: dependencies.cardTokenizer,
              publicKey: dependencies.apiConfig.mercadoPagoPublicKey,
              onPaymentConfirmed: (purchaseId, tripId) {
                context.go(
                  '/paid-handoff?tripId=$tripId&purchaseId=$purchaseId',
                );
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
        GoRoute(
          path: '/paid-handoff',
          builder: (context, state) {
            final tripId = state.uri.queryParameters['tripId'] ?? '';
            final purchaseId = state.uri.queryParameters['purchaseId'] ?? '';
            return PaidTripHandoffPage(
              tripId: tripId,
              purchaseId: purchaseId,
              paymentsRepository: dependencies.paymentsRepository,
              tripsRepository: dependencies.tripsRepository,
              storage: TwoGoStorage(),
              onHandoffSuccess: (trip) {
                context.go('/app/trips');
              },
              onCancelled: () {
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
        return '/app/home';
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
