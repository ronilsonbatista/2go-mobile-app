import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

import '../../domain/models/home_crm_snapshot.dart';
import '../../domain/models/home_destination.dart';
import '../../domain/models/home_profile.dart';
import '../../domain/models/home_trip_day.dart';
import '../../domain/models/home_trip_summary.dart';
import 'home_crm_days_strip.dart';
import 'home_crm_outline_cta.dart';
import 'home_crm_tips_strip.dart';
import 'home_crm_trip_card.dart';
import 'home_destination_card.dart';
import 'home_profile_chip.dart';

/// Authenticated paid-trip Home CRM (designs Home-1…7).
///
/// Only built when [HomeCrmSnapshot.hasPaidTrip]. No trip → discovery Home.
class HomeCrmBody extends StatelessWidget {
  const HomeCrmBody({
    super.key,
    required this.profile,
    required this.crm,
    required this.destinations,
    required this.onCreateItinerary,
    required this.onAccessItineraries,
    required this.onProfileTap,
    required this.onDestinationTap,
    this.onTripTap,
    this.onDayTap,
    this.inspiredDestinations = const [],
    this.expiredDestinations = const [],
    this.now,
    this.showAccessLink = false,
  });

  final HomeProfile profile;
  final HomeCrmSnapshot crm;
  final List<HomeDestination> destinations;
  final VoidCallback onCreateItinerary;
  final VoidCallback onAccessItineraries;
  final VoidCallback onProfileTap;
  final ValueChanged<HomeDestination> onDestinationTap;
  final ValueChanged<HomeTripSummary>? onTripTap;
  final ValueChanged<HomeTripDay>? onDayTap;

  /// Optional "Roteiros inspirados" cards (local/catalog — no invented API).
  final List<HomeDestination> inspiredDestinations;

  /// Optional expired promo cards for Home CRM (design Home-1 / Home_0506).
  /// Empty → centered empty state (never São Paulo/Paris stubs).
  final List<HomeDestination> expiredDestinations;
  final DateTime Function()? now;
  final bool showAccessLink;

  String get _greeting {
    final name = profile.displayName?.trim();
    if (name == null || name.isEmpty) return 'Olá';
    final first = name.split(RegExp(r'\s+')).first;
    if (first.contains('@')) return 'Olá';
    final pretty = first[0].toUpperCase() + first.substring(1);
    return 'Olá, $pretty';
  }

  @override
  Widget build(BuildContext context) {
    final trip = crm.trip;
    if (trip == null) return const SizedBox.shrink();

    final tips = crm.tips.isNotEmpty ? crm.tips : trip.tips;
    final topPad = MediaQuery.paddingOf(context).top;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              TwoGoSpacing.lg,
              topPad + TwoGoSpacing.sm,
              TwoGoSpacing.sm,
              TwoGoSpacing.md,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _greeting,
                    style: TwoGoTypography.headlineMedium.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                HomeProfileChip(
                  profile: profile,
                  onTap: onProfileTap,
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: _NextTripSection(
            trip: trip,
            destinations: destinations,
            now: now,
            showAccessLink: showAccessLink,
            onCreateItinerary: onCreateItinerary,
            onAccessItineraries: onAccessItineraries,
            onTripTap: onTripTap,
            onDayTap: onDayTap,
          ),
        ),
        if (tips.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: TwoGoSpacing.lg),
              child: HomeCrmTipsStrip(tips: tips),
            ),
          ),
        if (inspiredDestinations.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: TwoGoSpacing.xl),
              child: _InspiredStrip(
                destinations: inspiredDestinations,
                onDestinationTap: onDestinationTap,
              ),
            ),
          ),
        if (destinations.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: TwoGoSpacing.xl),
              child: _DiscoveryPeek(
                destinations: destinations,
                onDestinationTap: onDestinationTap,
              ),
            ),
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: TwoGoSpacing.xl),
            child: _ExpiredPeek(
              destinations: expiredDestinations,
              onDestinationTap: onDestinationTap,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: TwoGoSpacing.xxl + MediaQuery.paddingOf(context).bottom,
          ),
        ),
      ],
    );
  }
}

class _NextTripSection extends StatelessWidget {
  const _NextTripSection({
    required this.trip,
    required this.destinations,
    required this.onCreateItinerary,
    required this.onAccessItineraries,
    this.onTripTap,
    this.onDayTap,
    this.now,
    this.showAccessLink = false,
  });

  final HomeTripSummary trip;
  final List<HomeDestination> destinations;
  final VoidCallback onCreateItinerary;
  final VoidCallback onAccessItineraries;
  final ValueChanged<HomeTripSummary>? onTripTap;
  final ValueChanged<HomeTripDay>? onDayTap;
  final DateTime Function()? now;
  final bool showAccessLink;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: TwoGoSpacing.lg),
          child: Text(
            'Próxima viagem 💚',
            style: TwoGoTypography.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: TwoGoSpacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: TwoGoSpacing.lg),
          child: HomeCrmTripCard(
            trip: trip,
            destinations: destinations,
            now: now,
            onTap: onTripTap == null ? null : () => onTripTap!(trip),
          ),
        ),
        if (trip.days.isNotEmpty) ...[
          const SizedBox(height: TwoGoSpacing.md),
          HomeCrmDaysStrip(days: trip.days, onDayTap: onDayTap),
        ],
        const SizedBox(height: TwoGoSpacing.lg),
        HomeCrmOutlineCta(onPressed: onCreateItinerary),
        if (showAccessLink) ...[
          const SizedBox(height: TwoGoSpacing.sm),
          Center(
            child: TextButton(
              onPressed: onAccessItineraries,
              child: Text(
                'Acessar roteiros',
                style: TwoGoTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: TwoGoColors.contentPrimary,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _DiscoveryPeek extends StatelessWidget {
  const _DiscoveryPeek({
    required this.destinations,
    required this.onDestinationTap,
  });

  final List<HomeDestination> destinations;
  final ValueChanged<HomeDestination> onDestinationTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: TwoGoSpacing.lg),
          child: Text(
            'Procurando algo novo? 🌏',
            style: TwoGoTypography.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: TwoGoSpacing.md),
        SizedBox(
          height: 196,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: TwoGoSpacing.lg),
            itemCount: destinations.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: TwoGoSpacing.sm),
            itemBuilder: (context, index) {
              final destination = destinations[index];
              return HomeDestinationCard(
                destination: destination,
                onTap: () => onDestinationTap(destination),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _InspiredStrip extends StatelessWidget {
  const _InspiredStrip({
    required this.destinations,
    required this.onDestinationTap,
  });

  final List<HomeDestination> destinations;
  final ValueChanged<HomeDestination> onDestinationTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: TwoGoSpacing.lg),
          child: Text(
            'Roteiros inspirados ✨',
            style: TwoGoTypography.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: TwoGoSpacing.md),
        SizedBox(
          height: 196,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: TwoGoSpacing.lg),
            itemCount: destinations.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: TwoGoSpacing.sm),
            itemBuilder: (context, index) {
              final destination = destinations[index];
              return HomeDestinationCard(
                destination: destination,
                onTap: () => onDestinationTap(destination),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Design Home-1 / Home_0506 — never invent São Paulo/Paris demo cards.
class _ExpiredPeek extends StatelessWidget {
  const _ExpiredPeek({
    required this.destinations,
    required this.onDestinationTap,
  });

  final List<HomeDestination> destinations;
  final ValueChanged<HomeDestination> onDestinationTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TwoGoSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Roteiros expirados 📁',
            style: TwoGoTypography.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: TwoGoSpacing.sm),
          if (destinations.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: TwoGoSpacing.xl),
              child: Center(
                child: Text(
                  'Não temos roteiros expirados por aqui.',
                  textAlign: TextAlign.center,
                  style: TwoGoTypography.bodyMedium,
                ),
              ),
            )
          else ...[
            Text(
              'Ainda pretende viajar para esses destinos? Aproveite a '
              'promoção e reative o roteiro com uma nova data.',
              style: TwoGoTypography.bodyMedium.copyWith(
                color: TwoGoColors.contentSecondary,
              ),
            ),
            const SizedBox(height: TwoGoSpacing.md),
            SizedBox(
              height: 168,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: destinations.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: TwoGoSpacing.sm),
                itemBuilder: (context, index) {
                  final destination = destinations[index];
                  return HomeDestinationCard(
                    destination: destination,
                    width: 140,
                    height: 168,
                    onTap: () => onDestinationTap(destination),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
