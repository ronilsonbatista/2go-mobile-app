import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:twogo_authentication/twogo_authentication.dart';
import 'package:twogo_checkout/twogo_checkout.dart';
import 'package:twogo_planning/twogo_planning.dart';
import 'package:twogo_profile/profile.dart';
import 'package:twogo_session/twogo_session.dart';
import 'package:twogo_storage/twogo_storage.dart';
import 'package:twogo_trips/trips.dart';

import '../debug/debug_preview_repository.dart';
import '../di/app_dependencies.dart';
import '../pages/home_page.dart';
import '../pages/launch_page.dart';
import '../pages/notifications_page.dart';
import '../pages/profile_page.dart';
import '../pages/trips_page.dart';
import '../planning/preview_day1_interactions.dart';
import '../shell/app_shell.dart';

class AppRouter {
  /// Root navigator — full-screen flows (Q&A / auth / checkout) cover the
  /// tab shell so [TwoGoBottomNavigation] is never visible on those routes.
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  static const _guestAllowedPrefixes = <String>[
    '/launch',
    '/debug',
    '/auth',
    '/app',
    '/planning',
    '/trips',
  ];

  static bool isFullScreenPath(String location) {
    return location.startsWith('/planning') ||
        location == '/auth' ||
        location.startsWith('/auth/') ||
        location == '/checkout' ||
        location.startsWith('/checkout') ||
        location == '/paid-handoff' ||
        location.startsWith('/paid-handoff') ||
        location.startsWith('/trips/') ||
        location == '/launch' ||
        location.startsWith('/debug/');
  }

  /// Optional debug override, e.g. `--dart-define=TWIGO_DEBUG_INITIAL_ROUTE=/debug/gerando`, `/debug/hotel`, or `/debug/preview`.
  static const String debugInitialRoute = String.fromEnvironment(
    'TWIGO_DEBUG_INITIAL_ROUTE',
  );

  static GoRouter createRouter({required AppDependencies dependencies}) {
    final sessionCubit = dependencies.sessionCubit;
    final intentStorage = dependencies.intentStorage;

    final initial = (kDebugMode && debugInitialRoute.isNotEmpty)
        ? debugInitialRoute
        : _getInitialLocation(sessionCubit.state.status);

    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: initial,
      refreshListenable: _GoRouterRefreshStream(sessionCubit.stream),
      redirect: (context, state) async {
        final sessionStatus = sessionCubit.state.status;
        final location = state.matchedLocation;

        // Keep debug preview routes sticky while capturing screenshots.
        if (kDebugMode &&
            debugInitialRoute.isNotEmpty &&
            location.startsWith('/debug/')) {
          return null;
        }

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
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const LaunchPage(),
        ),
        // Debug-only: hold Splash for visual certification without delaying prod cold-start.
        if (kDebugMode)
          GoRoute(
            path: '/debug/splash',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => const LaunchPage(),
          ),
        // Debug-only: Gerando loading UI for visual QA (no network).
        if (kDebugMode)
          GoRoute(
            path: '/debug/gerando',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) {
              return Scaffold(
                backgroundColor: Colors.white,
                body: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 32,
                    ),
                    child: Column(
                      children: [
                        const Spacer(flex: 2),
                        const GerandoRoteiroHero(size: 240),
                        const SizedBox(height: 28),
                        Text(
                          'Gerando seu roteiro...',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const Spacer(flex: 3),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        if (kDebugMode)
          GoRoute(
            path: '/debug/hotel',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) {
              return AddAccommodationSearchPage(
                controls: TripControls(
                  repository: dependencies.tripsRepository,
                  reloadTrip: () async {},
                  searchHotels: dependencies.searchHotelsUseCase,
                  getPlaceDetails: dependencies.getPlaceDetailsUseCase,
                ),
                tripId: 'debug-preview',
                searchHotels: dependencies.searchHotelsUseCase,
                getPlaceDetails: dependencies.getPlaceDetailsUseCase,
                biasLatitude: 41.9028,
                biasLongitude: 12.4964,
                previewOnly: true,
              );
            },
          ),
        // Debug-only: day-1 preview UI with fixture data (no network).
        if (kDebugMode)
          GoRoute(
            path: '/debug/preview',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) {
              final interactions = PreviewDay1Interactions(dependencies);
              final bloc = PlanningPreviewBloc(
                getPreviewUseCase: GetPlanningPreviewUseCase(
                  DebugPreviewRepository(),
                ),
              );
              return PlanningPreviewPage(
                journeyId: 'debug-preview',
                bloc: bloc,
                now: () => DateTime(2026, 6, 30, 12, 0),
                onBack: () => context.go('/app/home'),
                loadCoverCatalog: interactions.loadCoverCatalog,
                onAddLodging: () {
                  // Fixture preview — lodging still opens existing search UI.
                  showAddAccommodationFlow(
                    context,
                    controls: TripControls(
                      repository: dependencies.tripsRepository,
                      reloadTrip: () async {},
                      searchHotels: dependencies.searchHotelsUseCase,
                      getPlaceDetails: dependencies.getPlaceDetailsUseCase,
                    ),
                    tripId: 'debug-preview',
                    searchHotels: dependencies.searchHotelsUseCase,
                    getPlaceDetails: dependencies.getPlaceDetailsUseCase,
                    biasLatitude: 41.9028,
                    biasLongitude: 12.4964,
                    previewOnly: true,
                  );
                },
                onActivityTap: (activity) {
                  interactions.openActivityDetails(
                    context,
                    activity: activity,
                  );
                },
                onShare: () {
                  context.push(
                    '/trips/debug-preview/share?name=${Uri.encodeComponent('Roma')}',
                  );
                },
                onUnlockRequested: (id, productId) {
                  context.go('/auth');
                },
              );
            },
          ),
        GoRoute(
          path: '/auth',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) {
            return BlocProvider<AuthenticationBloc>(
              create: (context) => AuthenticationBloc(
                requestOtpUseCase: RequestOtpUseCase(
                  dependencies.authRepository,
                ),
                verifyOtpUseCase: VerifyOtpUseCase(dependencies.authRepository),
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
        // Q&A Form Course — root navigator, never under AppShell tab bar.
        GoRoute(
          path: '/planning/wizard',
          parentNavigatorKey: rootNavigatorKey,
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
          parentNavigatorKey: rootNavigatorKey,
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
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) {
            final journeyId = state.pathParameters['journeyId']!;
            final interactions = PreviewDay1Interactions(dependencies);
            final bloc = dependencies.createPlanningPreviewBloc();
            return PlanningPreviewPage(
              journeyId: journeyId,
              bloc: bloc,
              loadCoverCatalog: interactions.loadCoverCatalog,
              onAddLodging: () {
                final current = bloc.state;
                if (current is! PlanningPreviewLoadedState) return;
                interactions.openAddLodging(
                  context,
                  preview: current.preview,
                );
              },
              onActivityTap: (activity) {
                interactions.openActivityDetails(
                  context,
                  activity: activity,
                );
              },
              onShare: () {
                final current = bloc.state;
                final preview = current is PlanningPreviewLoadedState
                    ? current.preview
                    : null;
                final name = preview == null
                    ? 'Viagem'
                    : _destinationNameFromPreview(preview);
                final q = <String, String>{
                  'name': name,
                  if (preview?.summary.resolvedCoverImageUrl != null)
                    'cover': preview!.summary.resolvedCoverImageUrl!,
                  if (preview?.summary.startDate != null)
                    'start': preview!.summary.startDate!,
                  if (preview?.summary.endDate != null)
                    'end': preview!.summary.endDate!,
                };
                final query = q.entries
                    .map(
                      (e) =>
                          '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
                    )
                    .join('&');
                // Day-1 uses journey id; Core participants need a trip id
                // (post-claim). Same route works for paid trips.
                context.push('/trips/$journeyId/share?$query');
              },
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
          path: '/trips/:tripId/share',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) {
            final tripId = state.pathParameters['tripId']!;
            final q = state.uri.queryParameters;
            return TripSharePage(
              tripId: tripId,
              apiClient: dependencies.tripShareApiClient,
              destinationName: q['name'] ?? 'Viagem',
              coverImageUrl: q['cover'],
              startDate: DateTime.tryParse(q['start'] ?? ''),
              endDate: DateTime.tryParse(q['end'] ?? ''),
              onBack: () => context.pop(),
            );
          },
        ),
        GoRoute(
          path: '/planning/claim',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) {
            final journeyId = state.uri.queryParameters['journeyId'] ?? '';
            final productId = state.uri.queryParameters['productId'];
            return PlanningClaimPage(
              journeyId: journeyId,
              productId: productId?.isEmpty == true ? null : productId,
              bloc: dependencies.createPlanningClaimBloc(),
              onClaimed: (tripId, nextAction) {
                context.go(
                  claimNavigationPath(tripId: tripId, nextAction: nextAction),
                );
              },
            );
          },
        ),
        GoRoute(
          path: '/checkout',
          parentNavigatorKey: rootNavigatorKey,
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
          parentNavigatorKey: rootNavigatorKey,
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
                context.go(
                  '/app/trips?tripId=${Uri.encodeQueryComponent(trip.id)}',
                );
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
                  builder: (context, state) => HomePage(
                    homeCubit: dependencies.createHomeCubit(),
                    seedHomeDestinationDraft:
                        dependencies.seedHomeDestinationDraftUseCase,
                    tripShareApiClient: dependencies.tripShareApiClient,
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/app/trips',
                  builder: (context, state) {
                    final tripId = state.uri.queryParameters['tripId'];
                    final inviteAccepted =
                        state.uri.queryParameters['inviteAccepted'] == '1';
                    return TripsPage(
                      tripsRepository: dependencies.tripsRepository,
                      tripId: tripId,
                      searchHotels: dependencies.searchHotelsUseCase,
                      getPlaceDetails: dependencies.getPlaceDetailsUseCase,
                      searchPlaces: dependencies.searchPlacesUseCase,
                      showInviteAcceptedToast: inviteAccepted,
                      onShare: (trip) {
                        final q = <String, String>{
                          'name': trip.destination.isNotEmpty
                              ? trip.destination
                              : trip.title,
                          if (trip.coverImage != null) 'cover': trip.coverImage!,
                          if (trip.startDate != null)
                            'start': trip.startDate!.toIso8601String(),
                          if (trip.endDate != null)
                            'end': trip.endDate!.toIso8601String(),
                        };
                        final query = q.entries
                            .map(
                              (e) =>
                                  '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
                            )
                            .join('&');
                        context.push('/trips/${trip.id}/share?$query');
                      },
                    );
                  },
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
                ShellRoute(
                  builder: (context, state, child) {
                    final email = sessionCubit.state.userId;
                    return ProfileScope(
                      repository: dependencies.accountProfileRepository,
                      fallbackEmail: email,
                      child: child,
                    );
                  },
                  routes: [
                    GoRoute(
                      path: '/app/profile',
                      builder: (context, state) => const ProfilePage(),
                      routes: [
                        GoRoute(
                          path: 'personal-data',
                          builder: (context, state) => PersonalDataPage(
                            onBack: () => context.pop(),
                          ),
                        ),
                        GoRoute(
                          path: 'saved-cards',
                          builder: (context, state) => SavedCardsPage(
                            onBack: () => context.pop(),
                          ),
                        ),
                        GoRoute(
                          path: 'expired-itineraries',
                          builder: (context, state) =>
                              ExpiredItinerariesPage(
                            onBack: () => context.pop(),
                          ),
                        ),
                        GoRoute(
                          path: 'change-photo',
                          builder: (context, state) {
                            final path = state.extra is String
                                ? state.extra! as String
                                : '';
                            return ChangePhotoPage(
                              imagePath: path,
                              onBack: () => context.pop(),
                              onSaved: () => context.pop(),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
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

  static String _destinationNameFromPreview(PlanningPreview preview) {
    final destinations = preview.summary.destinations;
    if (destinations.isNotEmpty && destinations[0] is Map) {
      return (destinations[0] as Map)['name']?.toString() ?? 'Viagem';
    }
    return 'Viagem';
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
