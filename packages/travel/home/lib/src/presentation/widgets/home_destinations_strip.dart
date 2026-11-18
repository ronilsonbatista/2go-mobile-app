import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

import '../../domain/models/home_destination.dart';
import 'home_destination_card.dart';

class HomeDestinationsStrip extends StatelessWidget {
  const HomeDestinationsStrip({
    required this.destinations,
    required this.onDestinationTap,
    super.key,
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
            'Destinos em alta ✈️',
            style: TwoGoTypography.headlineSmall.copyWith(
              fontWeight: FontWeight.w700,
              color: TwoGoColors.contentPrimary,
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
            separatorBuilder: (_, __) => const SizedBox(width: TwoGoSpacing.sm),
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
