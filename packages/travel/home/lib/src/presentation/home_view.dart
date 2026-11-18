import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twogo_design_system/design_system.dart';
import 'package:twogo_session/twogo_session.dart';

import '../application/home_cubit.dart';
import 'widgets/home_cta_sheet.dart';
import 'widgets/home_destinations_strip.dart';
import 'widgets/home_hero_carousel.dart';
import 'widgets/home_profile_chip.dart';

/// Course Home layout (Home-9 guest / Home-10 photo / Home-11 initials).
class HomeView extends StatefulWidget {
  const HomeView({
    required this.onCreateItinerary,
    required this.onAccessItineraries,
    required this.onProfileTap,
    super.key,
  });

  final VoidCallback onCreateItinerary;
  final VoidCallback onAccessItineraries;
  final VoidCallback onProfileTap;

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
                final heroHeight = (constraints.maxHeight * 0.48)
                    .clamp(240.0, 420.0);

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

                // Course layout: hero + overlapping CTA sheet + destinations.
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
                                    context.read<HomeCubit>().setHeroIndex(
                                      index,
                                    ),
                              ),
                            ),
                            Positioned(
                              top: MediaQuery.paddingOf(context).top +
                                  TwoGoSpacing.sm,
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
                                onAccessItineraries:
                                    widget.onAccessItineraries,
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
              },
            ),
          );
        },
      ),
    );
  }
}
