import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:twogo_home/twogo_home.dart';
import 'package:twogo_planning/twogo_planning.dart';
import 'package:twogo_session/twogo_session.dart';
import 'package:twogo_trips/trips.dart';

import '../share/home_trip_welcome.dart';

/// Home route — course layout (guest silhouette / auth photo or initials).
class HomePage extends StatelessWidget {
  const HomePage({
    required this.homeCubit,
    required this.seedHomeDestinationDraft,
    this.tripShareApiClient,
    super.key,
  });

  final HomeCubit homeCubit;
  final SeedHomeDestinationDraftUseCase seedHomeDestinationDraft;
  final TripShareApiClient? tripShareApiClient;

  Future<void> _persistDestination(HomeDestination destination) {
    return seedHomeDestinationDraft(
      name: destination.name,
      country: destination.country,
      coverImageUrl:
          destination.resolvedCardUrl ?? destination.resolvedHeroUrl,
      // Google Places id from Core Home payload — enables Onde step-1
      // without re-search. Never invent from slug.
      providerPlaceId: destination.providerPlaceId,
    );
  }

  Future<void> _createItinerary(BuildContext context) async {
    // Onde starts EMPTY (no city/dates). Strip taps may still seed a city
    // without dates; CTA always opens a blank first destination.
    await seedHomeDestinationDraft.startEmpty();
    if (!context.mounted) return;
    // Push on the root navigator so Q&A covers AppShell (no tab bar).
    context.push('/planning/wizard');
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionCubit>().state;
    final shareClient = tripShareApiClient;

    Widget home = BlocProvider<HomeCubit>.value(
      value: homeCubit,
      child: HomeView(
        onCreateItinerary: () => _createItinerary(context),
        onAccessItineraries: () => context.go('/app/trips'),
        onProfileTap: () {
          final s = context.read<SessionCubit>().state;
          if (s.isAuthenticated) {
            context.go('/app/profile');
          } else {
            context.go('/auth');
          }
        },
        onDestinationSelected: (destination) {
          // Persist into users-defaults draft only — no Core trip/session POST.
          _persistDestination(destination);
        },
      ),
    );

    if (shareClient != null && session.isAuthenticated) {
      home = HomeTripWelcomeHost(
        apiClient: shareClient,
        child: home,
      );
    }

    return home;
  }
}
