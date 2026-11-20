import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twogo_design_system/design_system.dart';
import 'package:twogo_session/twogo_session.dart';

import '../application/home_cubit.dart';
import '../domain/models/home_destination.dart';
import '../domain/models/home_trip_summary.dart';
import 'widgets/home_crm_body.dart';
import 'widgets/home_cta_sheet.dart';
import 'widgets/home_destinations_strip.dart';
import 'widgets/home_hero_carousel.dart';
import 'widgets/home_profile_chip.dart';

/// Course Home layout (Home-9 guest / Home-10 photo / Home-11 initials)
/// plus authenticated CRM (Home-1…8) when [HomeShellMode.crm].
class HomeView extends StatefulWidget {
  const HomeView({
    required this.onCreateItinerary,
    required this.onAccessItineraries,
    required this.onProfileTap,
    this.onDestinationSelected,
    this.onTripSelected,
    this.showCrmAccessLink = false,
    this.now,
    super.key,
  });

  final VoidCallback onCreateItinerary;
  final VoidCallback onAccessItineraries;
  final VoidCallback onProfileTap;

  /// Fired when the user taps the hero or a "Destinos em alta" card.
  /// App shell seeds users-defaults and opens create-itinerary / Onde.
  final ValueChanged<HomeDestination>? onDestinationSelected;

  /// Opens owned trip detail (próxima viagem / expired card).
  final ValueChanged<HomeTripSummary>? onTripSelected;

  /// When true, CRM next-trip shows "Acessar roteiros" (Home-2).
  final bool showCrmAccessLink;

  /// Clock override for countdown tests / screenshots.
  final DateTime Function()? now;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncFromSession());
  }

  void _syncFromSession() {
    final session = context.read<SessionCubit>().state;
    context.read<HomeCubit>().load(
      isAuthenticated: session.isAuthenticated,
      userId: session.userId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SessionCubit, SessionState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          previous.userId != current.userId,
      listener: (context, session) {
        context.read<HomeCubit>().load(
          isAuthenticated: session.isAuthenticated,
          userId: session.userId,
        );
      },
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: TwoGoColors.backgroundPrimary,
            body: LayoutBuilder(
              builder: (context, constraints) {
                if (state.status == HomeStatus.loading ||
                    state.status == HomeStatus.initial) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.status == HomeStatus.failure) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(TwoGoSpacing.lg),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Não foi possível carregar a Home.',
                            style: TwoGoTypography.titleLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: TwoGoSpacing.md),
                          TwoGoButton(
                            text: 'Tentar de novo',
                            onPressed: _syncFromSession,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state.shellMode == HomeShellMode.crm) {
                  return HomeCrmBody(
                    profile: state.profile,
                    crm: state.crm,
                    destinations: state.destinations,
                    onCreateItinerary: widget.onCreateItinerary,
                    onAccessItineraries: widget.onAccessItineraries,
                    onProfileTap: widget.onProfileTap,
                    showAccessLink: widget.showCrmAccessLink,
                    now: widget.now,
                    onDestinationTap: (destination) {
                      context.read<HomeCubit>().selectDestination(
                            destination.id,
                          );
                      widget.onDestinationSelected?.call(destination);
                    },
                    onTripTap: widget.onTripSelected,
                  );
                }

                return _buildDiscovery(context, state, constraints);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildDiscovery(
    BuildContext context,
    HomeState state,
    BoxConstraints constraints,
  ) {
    final heroHeight =
        (constraints.maxHeight * 0.48).clamp(240.0, 420.0);
    const sheetOverlap = 36.0;
    const sheetBodyEstimate = 168.0;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(
            height: heroHeight + sheetBodyEstimate - sheetOverlap,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: heroHeight,
                  child: HomeHeroCarousel(
                    destinations: state.destinations,
                    index: state.heroIndex,
                    onIndexChanged: (index) =>
                        context.read<HomeCubit>().setHeroIndex(index),
                    onDestinationTap: (destination) {
                      context.read<HomeCubit>().selectDestination(
                            destination.id,
                          );
                      widget.onDestinationSelected?.call(destination);
                    },
                  ),
                ),
                Positioned(
                  top: MediaQuery.paddingOf(context).top + TwoGoSpacing.sm,
                  right: TwoGoSpacing.sm,
                  child: HomeProfileChip(
                    profile: state.profile,
                    onTap: widget.onProfileTap,
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: heroHeight - sheetOverlap,
                  child: HomeCtaSheet(
                    onCreateItinerary: widget.onCreateItinerary,
                    onAccessItineraries: widget.onAccessItineraries,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: ColoredBox(
            color: TwoGoColors.backgroundPrimary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                HomeDestinationsStrip(
                  destinations: state.destinations,
                  onDestinationTap: (destination) {
                    context.read<HomeCubit>().selectDestination(
                          destination.id,
                        );
                    widget.onDestinationSelected?.call(destination);
                  },
                ),
                SizedBox(
                  height: TwoGoSpacing.xxl +
                      MediaQuery.paddingOf(context).bottom,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
