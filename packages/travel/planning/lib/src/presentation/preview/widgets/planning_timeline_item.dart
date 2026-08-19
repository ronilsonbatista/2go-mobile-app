import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';
import '../../../domain/models/planning_preview.dart';

class PlanningTimelineItem extends StatelessWidget {
  final PlanningVisibleActivity activity;
  final bool isLast;

  const PlanningTimelineItem({
    super.key,
    required this.activity,
    this.isLast = false,
  });

  IconData _getCategoryIcon(String category) {
    switch (category.toUpperCase()) {
      case 'TOURIST_ATTRACTION':
        return Icons.nature_people_rounded;
      case 'MUSEUM':
        return Icons.museum_rounded;
      case 'RESTAURANT':
        return Icons.restaurant_rounded;
      case 'PARK':
        return Icons.park_rounded;
      case 'HOTEL':
      case 'ACCOMMODATION':
        return Icons.hotel_rounded;
      case 'SHOPPING':
        return Icons.shopping_bag_rounded;
      default:
        return Icons.place_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator column
          Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: TwoGoColors.neutral800,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getCategoryIcon(activity.category),
                  color: TwoGoColors.brandLime,
                  size: 18,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: TwoGoColors.neutral200,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: TwoGoSpacing.md),
          // Content card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: TwoGoSpacing.lg),
              child: TwoGoCard(
                child: Padding(
                  padding: const EdgeInsets.all(TwoGoSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (activity.period != null)
                            TwoGoPill(
                              label: activity.period!,
                              variant: TwoGoPillVariant.neutral,
                            ),
                          if (activity.isCurated)
                            const TwoGoBadge(
                              label: 'Curadoria 2GO',
                              variant: TwoGoBadgeVariant.brand,
                            ),
                        ],
                      ),
                      const SizedBox(height: TwoGoSpacing.sm),
                      Text(
                        activity.title,
                        style: TwoGoTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: TwoGoColors.neutral900,
                        ),
                      ),
                      if (activity.description != null &&
                          activity.description!.isNotEmpty) ...[
                        const SizedBox(height: TwoGoSpacing.xs),
                        Text(
                          activity.description!,
                          style: TwoGoTypography.bodySmall.copyWith(
                            color: TwoGoColors.neutral700,
                          ),
                        ),
                      ],
                      if (activity.location != null &&
                          activity.location!.isNotEmpty) ...[
                        const SizedBox(height: TwoGoSpacing.sm),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: TwoGoColors.neutral500,
                            ),
                            const SizedBox(width: TwoGoSpacing.xs),
                            Expanded(
                              child: Text(
                                activity.location!,
                                style: TwoGoTypography.labelSmall.copyWith(
                                  color: TwoGoColors.neutral600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (activity.cost > 0) ...[
                        const SizedBox(height: TwoGoSpacing.xs),
                        Text(
                          'Custo estimado: R\$ ${activity.cost.toStringAsFixed(2)}',
                          style: TwoGoTypography.labelSmall.copyWith(
                            color: TwoGoColors.brandLimePressed,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
