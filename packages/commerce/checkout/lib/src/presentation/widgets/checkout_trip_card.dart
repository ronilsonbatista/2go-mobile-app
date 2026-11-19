import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

import '../../domain/checkout_trip_preview.dart';

/// Trip summary card at the top of Carrinho (destino / pessoas / datas).
class CheckoutTripCard extends StatelessWidget {
  final CheckoutTripPreview trip;

  const CheckoutTripCard({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(TwoGoSpacing.sm),
      decoration: BoxDecoration(
        color: TwoGoColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(TwoGoRadius.large),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(TwoGoRadius.medium),
            child: SizedBox(
              width: 72,
              height: 72,
              child: _TripThumb(trip: trip),
            ),
          ),
          const SizedBox(width: TwoGoSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip.destination,
                  style: TwoGoTypography.titleMedium.copyWith(
                    color: TwoGoColors.contentPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: TwoGoSpacing.xxs),
                Text(
                  trip.peopleLabel,
                  style: TwoGoTypography.bodyMedium.copyWith(
                    color: TwoGoColors.contentSecondary,
                  ),
                ),
                Text(
                  trip.datesLabel,
                  style: TwoGoTypography.bodyMedium.copyWith(
                    color: TwoGoColors.contentSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: TwoGoColors.neutral0,
              shape: BoxShape.circle,
              border: Border.all(color: TwoGoColors.borderDefault),
            ),
            child: const Icon(
              Icons.flight_takeoff_rounded,
              size: 18,
              color: TwoGoColors.contentPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TripThumb extends StatelessWidget {
  const _TripThumb({required this.trip});

  final CheckoutTripPreview trip;

  @override
  Widget build(BuildContext context) {
    if (trip.imageUrl != null && trip.imageUrl!.isNotEmpty) {
      return Image.network(
        trip.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _PlaceholderThumb(),
      );
    }
    if (trip.imageAssetPath != null && trip.imageAssetPath!.isNotEmpty) {
      return Image.asset(
        trip.imageAssetPath!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _PlaceholderThumb(),
      );
    }
    return const _PlaceholderThumb();
  }
}

class _PlaceholderThumb extends StatelessWidget {
  const _PlaceholderThumb();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: TwoGoColors.neutral200,
      child: const Center(
        child: Icon(
          Icons.location_city_rounded,
          color: TwoGoColors.contentSecondary,
        ),
      ),
    );
  }
}
