import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

import '../../domain/models/home_trip_summary.dart';
import 'home_crm_countdown.dart';
import 'home_destination_image.dart';

/// Large "Próxima viagem" photo card (design Home-1…7).
class HomeCrmTripCard extends StatelessWidget {
  const HomeCrmTripCard({
    super.key,
    required this.trip,
    this.onTap,
    this.showCountdown = true,
    this.now,
    this.width,
    this.height = 220,
  });

  final HomeTripSummary trip;
  final VoidCallback? onTap;
  final bool showCountdown;
  final DateTime Function()? now;
  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final lines = trip.stackedDestinationLines;
    final datePrimary = trip.dateRangePrimary;
    final dateSecondary = trip.dateRangeSecondary;

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: TwoGoColors.neutral200,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              HomeDestinationImage(
                imageUrl: trip.coverImageUrl,
                fit: BoxFit.cover,
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x22000000),
                      Color(0x00000000),
                      Color(0x99000000),
                    ],
                    stops: [0, 0.45, 1],
                  ),
                ),
              ),
              if (showCountdown && trip.countdownTarget != null)
                Positioned(
                  top: TwoGoSpacing.md,
                  right: TwoGoSpacing.md,
                  child: HomeCrmCountdown(
                    target: trip.countdownTarget,
                    now: now,
                  ),
                ),
              Positioned(
                left: TwoGoSpacing.md,
                right: TwoGoSpacing.md,
                bottom: TwoGoSpacing.md,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (var i = 0; i < lines.length; i++)
                            Text(
                              lines[i],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TwoGoTypography.headlineSmall.copyWith(
                                color: TwoGoColors.neutral0,
                                fontWeight: FontWeight.w800,
                                fontSize: i == 0 ? 28 : 22,
                                height: 1.05,
                                shadows: const [
                                  Shadow(
                                    blurRadius: 8,
                                    color: Color(0x66000000),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (datePrimary != null || dateSecondary != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (datePrimary != null)
                            Text(
                              datePrimary,
                              style: TwoGoTypography.bodySmall.copyWith(
                                color: TwoGoColors.neutral0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          if (dateSecondary != null)
                            Text(
                              dateSecondary,
                              style: TwoGoTypography.bodySmall.copyWith(
                                color: TwoGoColors.neutral0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
