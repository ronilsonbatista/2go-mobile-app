import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:twogo_home/twogo_home.dart';
import 'package:twogo_planning/twogo_planning.dart';
import 'package:twogo_session/twogo_session.dart';

/// Home route — course layout (guest silhouette / auth photo or initials).
class HomePage extends StatelessWidget {
  const HomePage({
    required this.homeCubit,
    required this.seedHomeDestinationDraft,
    super.key,
  });

  final HomeCubit homeCubit;
  final SeedHomeDestinationDraftUseCase seedHomeDestinationDraft;

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

  Future<void> _openOndeWithDestination(
    BuildContext context,
    HomeDestination destination,
  ) async {
    // Persist into users-defaults draft only — no Core trip/session POST.
    await _persistDestination(destination);
    if (!context.mounted) return;
    // Push on the root navigator so Q&A covers AppShell (no tab bar).
    context.push('/planning/wizard');
  }

  Future<void> _createItinerary(BuildContext context) async {
    // CTA keeps Onde empty (no city/dates). Hero / strip taps seed a city.
    await seedHomeDestinationDraft.startEmpty();
    if (!context.mounted) return;
    // Push on the root navigator so Q&A covers AppShell (no tab bar).
    context.push('/planning/wizard');
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeCubit>.value(
      value: homeCubit,
      child: HomeView(
        onCreateItinerary: () => _createItinerary(context),
        onAccessItineraries: () => context.go('/app/trips'),
        onProfileTap: () {
          final session = context.read<SessionCubit>().state;
          if (session.isAuthenticated) {
            context.go('/app/profile');
          } else {
            context.go('/auth');
          }
        },
        onDestinationSelected: (destination) {
          _openOndeWithDestination(context, destination);
        },
      ),
    );
  }
}
