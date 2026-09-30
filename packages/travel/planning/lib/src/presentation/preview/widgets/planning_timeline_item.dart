import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';
import '../../../domain/models/planning_preview.dart';

class PlanningTimelineItem extends StatelessWidget {
  final PlanningVisibleActivity activity;
  final bool isLast;
  final ValueChanged<Uri>? onOpenUrl;
  final ImageProvider Function(String url)? imageProviderBuilder;

  const PlanningTimelineItem({
    super.key,
    required this.activity,
    this.isLast = false,
    this.onOpenUrl,
    this.imageProviderBuilder,
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
      case 'CAFE':
        return Icons.local_cafe_rounded;
      case 'BAR':
        return Icons.local_bar_rounded;
      default:
        return Icons.place_rounded;
    }
  }

  static String? mapUrl({double? latitude, double? longitude}) {
    if (latitude == null || longitude == null) return null;
    return 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
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
                      if (activity.imageUrl != null &&
                          activity.imageUrl!.isNotEmpty) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image(
                            image: imageProviderBuilder != null
                                ? imageProviderBuilder!(activity.imageUrl!)
                                : NetworkImage(activity.imageUrl!),
                            height: 140,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const SizedBox.shrink(),
                          ),
                        ),
                        const SizedBox(height: TwoGoSpacing.sm),
                      ],
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
                      if (_mapLink != null ||
                          _hasLink(activity.ticketUrl) ||
                          _hasLink(activity.reservationUrl)) ...[
                        const SizedBox(height: TwoGoSpacing.sm),
                        Wrap(
                          spacing: TwoGoSpacing.sm,
                          children: [
                            if (_mapLink != null)
                              _linkButton('Ver no mapa', _mapLink!),
                            if (_hasLink(activity.ticketUrl))
                              _linkButton('Ingresso', activity.ticketUrl!),
                            if (_hasLink(activity.reservationUrl))
                              _linkButton('Reserva', activity.reservationUrl!),
                          ],
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

  String? get _mapLink =>
      mapUrl(latitude: activity.latitude, longitude: activity.longitude);

  bool _hasLink(String? value) => value != null && value.trim().isNotEmpty;

  Widget _linkButton(String label, String url) {
    final uri = Uri.tryParse(url);
    final canOpen = uri != null && onOpenUrl != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (canOpen)
          TextButton(onPressed: () => onOpenUrl!(uri), child: Text(label))
        else
          Text(
            label,
            style: TwoGoTypography.labelSmall.copyWith(
              color: TwoGoColors.neutral800,
              fontWeight: FontWeight.w600,
            ),
          ),
        SelectableText(
          url,
          style: TwoGoTypography.labelSmall.copyWith(
            color: TwoGoColors.brandLimePressed,
          ),
        ),
      ],
    );
  }
}
