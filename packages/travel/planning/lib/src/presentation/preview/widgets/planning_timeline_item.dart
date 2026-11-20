import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

import '../../../domain/models/planning_preview.dart';

/// Timeline node styles for the day-1 preview.
enum PlanningTimelineNodeStyle { dashed, solid }

/// Card corner radius sampled vs design-preview-roma (between DS medium/large).
const double _kPreviewCardRadius = 12;

/// Activity title size — design/user shots read ~15–16pt, not titleSmall (12).
const TextStyle _kActivityTitleStyle = TextStyle(
  fontFamily: TwoGoTypography.fontFamily,
  fontSize: 15,
  fontWeight: FontWeight.w700,
  height: 1.3,
  color: TwoGoColors.contentPrimary,
);

class PlanningTimelineItem extends StatelessWidget {
  final PlanningVisibleActivity activity;
  final bool isLast;
  final PlanningTimelineNodeStyle nodeStyle;
  final ValueChanged<Uri>? onOpenUrl;
  final ImageProvider Function(String url)? imageProviderBuilder;
  final VoidCallback? onMenuTap;
  final VoidCallback? onRecommendationsTap;
  final VoidCallback? onTap;

  const PlanningTimelineItem({
    super.key,
    required this.activity,
    this.isLast = false,
    this.nodeStyle = PlanningTimelineNodeStyle.solid,
    this.onOpenUrl,
    this.imageProviderBuilder,
    this.onMenuTap,
    this.onRecommendationsTap,
    this.onTap,
  });

  static String? mapUrl({double? latitude, double? longitude}) {
    if (latitude == null || longitude == null) return null;
    return 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
  }

  static String costLabel(double cost) {
    if (cost <= 0) return 'Grátis';
    if (cost < 25) return '\$';
    if (cost < 60) return '\$\$';
    return '\$\$\$';
  }

  static String? transitBetween(
    PlanningVisibleActivity a,
    PlanningVisibleActivity b,
  ) {
    if (a.latitude == null ||
        a.longitude == null ||
        b.latitude == null ||
        b.longitude == null) {
      return null;
    }
    final meters = _haversineMeters(
      a.latitude!,
      a.longitude!,
      b.latitude!,
      b.longitude!,
    );
    if (meters < 80) return null;
    final km = meters / 1000.0;
    final minutes = math.max(5, (meters / 80).round()); // ~walking
    final kmLabel = km < 10
        ? km.toStringAsFixed(1).replaceAll('.', ',')
        : km.round().toString();
    return 'Deslocamento: $kmLabel KM ($minutes minutos)';
  }

  static double _haversineMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const r = 6371000.0;
    final dLat = _rad(lat2 - lat1);
    final dLon = _rad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_rad(lat1)) *
            math.cos(_rad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    return 2 * r * math.asin(math.sqrt(a));
  }

  static double _rad(double deg) => deg * math.pi / 180.0;

  bool get _mealSelected {
    if (!activity.isMeal) return false;
    final hasPlace = activity.providerPlaceId?.trim().isNotEmpty ?? false;
    if (hasPlace) return true;
    return !MealTypeAssets.isGenericMealTitle(activity.title) &&
        (activity.latitude != null ||
            (activity.imageUrl?.trim().isNotEmpty ?? false));
  }

  @override
  Widget build(BuildContext context) {
    if (activity.isTransport) {
      return _TransportRow(
        label: activity.timeLabel?.isNotEmpty == true
            ? activity.timeLabel!
            : (activity.title.isNotEmpty
                ? activity.title
                : 'Deslocamento'),
        isLast: isLast,
      );
    }

    final mealSelected = _mealSelected;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TimelineRail(
            style: nodeStyle,
            isLast: isLast,
            filled: activity.isMeal && mealSelected,
            child: activity.isMeal
                ? (mealSelected
                    ? const Icon(
                        Icons.check,
                        size: 14,
                        color: TwoGoColors.neutral0,
                      )
                    : null)
                : null,
          ),
          const SizedBox(width: TwoGoSpacing.sm),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: TwoGoSpacing.sm),
              child: activity.isMeal
                  ? _MealCard(
                      activity: activity,
                      selected: mealSelected,
                      imageProviderBuilder: imageProviderBuilder,
                      onTap: onTap,
                      onRecommendationsTap: onRecommendationsTap,
                      onMenuTap: onMenuTap,
                    )
                  : _AttractionCard(
                      activity: activity,
                      imageProviderBuilder: imageProviderBuilder,
                      onMenuTap: onMenuTap,
                      onTap: onTap,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Static lodging CTA at the top of the day timeline (guest preview).
class PlanningLodgingTimelineItem extends StatelessWidget {
  const PlanningLodgingTimelineItem({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _TimelineRail(
            style: PlanningTimelineNodeStyle.dashed,
            isLast: false,
            child: Icon(
              Icons.home_outlined,
              size: 14,
              color: TwoGoColors.neutral600,
            ),
          ),
          const SizedBox(width: TwoGoSpacing.sm),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: TwoGoSpacing.sm),
              child: Material(
                color: TwoGoColors.neutral100,
                borderRadius: BorderRadius.circular(_kPreviewCardRadius),
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(_kPreviewCardRadius),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: TwoGoSpacing.sm,
                      vertical: TwoGoSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: TwoGoColors.neutral0,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.apartment_outlined,
                            size: 22,
                            color: TwoGoColors.neutral600,
                          ),
                        ),
                        const SizedBox(width: TwoGoSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Adicionar hospedagem',
                                style: _kActivityTitleStyle.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'para estimar o deslocamento',
                                style: TwoGoTypography.labelSmall.copyWith(
                                  color: TwoGoColors.contentSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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

class PlanningTransitLabel extends StatelessWidget {
  const PlanningTransitLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 44,
        bottom: TwoGoSpacing.sm,
      ),
      child: Text(
        label,
        style: TwoGoTypography.labelSmall.copyWith(
          color: TwoGoColors.contentSecondary,
        ),
      ),
    );
  }
}

class _TimelineRail extends StatelessWidget {
  const _TimelineRail({
    required this.style,
    required this.isLast,
    this.child,
    this.filled = false,
  });

  final PlanningTimelineNodeStyle style;
  final bool isLast;
  final Widget? child;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final isDashed = style == PlanningTimelineNodeStyle.dashed;
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? TwoGoColors.neutral900 : TwoGoColors.neutral0,
            border: Border.all(
              color: TwoGoColors.neutral800,
              width: 1.5,
            ),
          ),
          child: child ??
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: TwoGoColors.neutral900,
                  shape: BoxShape.circle,
                ),
              ),
        ),
        if (!isLast)
          Expanded(
            child: CustomPaint(
              painter: _RailPainter(dashed: isDashed),
              child: const SizedBox(width: 2),
            ),
          ),
      ],
    );
  }
}

class _RailPainter extends CustomPainter {
  _RailPainter({required this.dashed});

  final bool dashed;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = TwoGoColors.neutral800
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final x = size.width / 2;
    if (!dashed) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      return;
    }
    const dash = 4.0;
    const gap = 3.0;
    var y = 0.0;
    while (y < size.height) {
      canvas.drawLine(
        Offset(x, y),
        Offset(x, math.min(y + dash, size.height)),
        paint,
      );
      y += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _RailPainter oldDelegate) =>
      oldDelegate.dashed != dashed;
}

class _MealCard extends StatelessWidget {
  const _MealCard({
    required this.activity,
    required this.selected,
    this.imageProviderBuilder,
    this.onTap,
    this.onRecommendationsTap,
    this.onMenuTap,
  });

  final PlanningVisibleActivity activity;
  final bool selected;
  final ImageProvider Function(String url)? imageProviderBuilder;
  final VoidCallback? onTap;
  final VoidCallback? onRecommendationsTap;
  final VoidCallback? onMenuTap;

  @override
  Widget build(BuildContext context) {
    final asset = MealTypeAssets.resolve(
      category: activity.category,
      title: activity.title,
      period: activity.period,
    );
    final remote = activity.imageUrl?.trim();
    final thumb = ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 52,
        height: 52,
        child: remote != null && remote.isNotEmpty
            ? Image(
                image:
                    imageProviderBuilder?.call(remote) ?? NetworkImage(remote),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Image.asset(
                  MealTypeAssets.pathFor(asset),
                  package: MealTypeAssets.package,
                  fit: BoxFit.cover,
                ),
              )
            : Image.asset(
                MealTypeAssets.pathFor(asset),
                package: MealTypeAssets.package,
                fit: BoxFit.cover,
              ),
      ),
    );

    return Material(
      color: TwoGoColors.neutral100,
      borderRadius: BorderRadius.circular(_kPreviewCardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_kPreviewCardRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: TwoGoSpacing.sm,
            vertical: TwoGoSpacing.sm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              thumb,
              const SizedBox(width: TwoGoSpacing.sm),
              Expanded(
                child: selected
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (activity.timeLabel != null &&
                              activity.timeLabel!.trim().isNotEmpty)
                            Text(
                              activity.timeLabel!,
                              style: TwoGoTypography.labelMedium.copyWith(
                                color: TwoGoColors.contentSecondary,
                                fontSize: 12,
                              ),
                            ),
                          Text(
                            activity.title,
                            style: _kActivityTitleStyle,
                          ),
                          if (activity.cost > 0)
                            Text(
                              PlanningTimelineItem.costLabel(activity.cost),
                              style: TwoGoTypography.labelMedium.copyWith(
                                color: TwoGoColors.info,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity.title,
                            style: _kActivityTitleStyle,
                          ),
                          const SizedBox(height: 3),
                          GestureDetector(
                            onTap: onRecommendationsTap,
                            child: Text(
                              'Ver recomendações',
                              style: TwoGoTypography.labelMedium.copyWith(
                                color: TwoGoColors.info,
                                fontSize: 12,
                                decoration: TextDecoration.underline,
                                decorationColor: TwoGoColors.info,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
              GestureDetector(
                onTap: onMenuTap,
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.more_vert_rounded,
                    size: 20,
                    color: TwoGoColors.neutral600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AttractionCard extends StatelessWidget {
  const _AttractionCard({
    required this.activity,
    this.imageProviderBuilder,
    this.onMenuTap,
    this.onTap,
  });

  final PlanningVisibleActivity activity;
  final ImageProvider Function(String url)? imageProviderBuilder;
  final VoidCallback? onMenuTap;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cost = PlanningTimelineItem.costLabel(activity.cost);
    final isFree = activity.cost <= 0;

    return Material(
      color: TwoGoColors.neutral0,
      borderRadius: BorderRadius.circular(_kPreviewCardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_kPreviewCardRadius),
        child: Container(
          padding: const EdgeInsets.all(TwoGoSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_kPreviewCardRadius),
            border: Border.all(color: TwoGoColors.neutral200),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 52,
                height: 52,
                child: (activity.imageUrl != null &&
                        activity.imageUrl!.isNotEmpty)
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image(
                          image: imageProviderBuilder != null
                              ? imageProviderBuilder!(activity.imageUrl!)
                              : NetworkImage(activity.imageUrl!),
                          width: 52,
                          height: 52,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _thumbFallback(),
                        ),
                      )
                    : _thumbFallback(),
              ),
              const SizedBox(width: TwoGoSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: _kActivityTitleStyle,
                    ),
                    if (activity.timeLabel != null &&
                        activity.timeLabel!.trim().isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        activity.timeLabel!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TwoGoTypography.labelMedium.copyWith(
                          color: TwoGoColors.contentSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: TwoGoSpacing.xs),
              // Trailing cost column mirrors design (Grátis / $ right of title).
              Text(
                cost,
                style: TwoGoTypography.labelMedium.copyWith(
                  color: isFree ? TwoGoColors.success : TwoGoColors.info,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              GestureDetector(
                onTap: onMenuTap,
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding: EdgeInsets.only(left: 2, top: 4, bottom: 4, right: 0),
                  child: Icon(
                    Icons.more_vert_rounded,
                    size: 20,
                    color: TwoGoColors.neutral600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _thumbFallback() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: TwoGoColors.neutral100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Icon(
          Icons.place_outlined,
          size: 22,
          color: TwoGoColors.neutral500,
        ),
      ),
    );
  }
}

class _TransportRow extends StatelessWidget {
  const _TransportRow({required this.label, required this.isLast});

  final String label;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 44,
        bottom: isLast ? 0 : TwoGoSpacing.sm,
      ),
      child: Text(
        label.startsWith('Deslocamento') ? label : 'Deslocamento: $label',
        style: TwoGoTypography.labelSmall.copyWith(
          color: TwoGoColors.contentSecondary,
        ),
      ),
    );
  }
}
