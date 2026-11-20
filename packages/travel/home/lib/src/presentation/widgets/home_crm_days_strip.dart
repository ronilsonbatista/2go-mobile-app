import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

import '../../domain/models/home_trip_day.dart';

/// Compact day chips from Core `days[]` (structure only — labels from backend).
class HomeCrmDaysStrip extends StatelessWidget {
  const HomeCrmDaysStrip({
    super.key,
    required this.days,
    this.onDayTap,
  });

  final List<HomeTripDay> days;
  final ValueChanged<HomeTripDay>? onDayTap;

  @override
  Widget build(BuildContext context) {
    if (days.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: TwoGoSpacing.lg),
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: TwoGoSpacing.xs),
        itemBuilder: (context, index) {
          final day = days[index];
          return Material(
            color: TwoGoColors.neutral100,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              onTap: onDayTap == null ? null : () => onDayTap!(day),
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: TwoGoSpacing.md,
                  vertical: TwoGoSpacing.xs,
                ),
                child: Center(
                  child: Text(
                    day.chipLabel,
                    style: TwoGoTypography.labelMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: TwoGoColors.contentPrimary,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
