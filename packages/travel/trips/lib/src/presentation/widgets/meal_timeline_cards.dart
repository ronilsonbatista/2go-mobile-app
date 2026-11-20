import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

import '../../domain/entities/itinerary_item_entity.dart';
import '../../domain/place_details_view_data.dart';

/// Shared meal-slot / selected-restaurant timeline cards (preview + paid).
class MealTimelineCard extends StatelessWidget {
  const MealTimelineCard({
    super.key,
    required this.title,
    this.subtitle,
    this.timeLabel,
    this.rating,
    this.priceRange,
    this.imageUrl,
    this.category,
    this.period,
    this.selected = false,
    this.onRecommendationsTap,
    this.onMenuTap,
    this.onTap,
    this.imageProviderBuilder,
  });

  final String title;
  final String? subtitle;
  final String? timeLabel;
  final double? rating;
  final String? priceRange;
  final String? imageUrl;
  final String? category;
  final String? period;
  final bool selected;
  final VoidCallback? onRecommendationsTap;
  final VoidCallback? onMenuTap;
  final VoidCallback? onTap;
  final ImageProvider Function(String url)? imageProviderBuilder;

  factory MealTimelineCard.fromItineraryItem(
    ItineraryItemEntity item, {
    VoidCallback? onRecommendationsTap,
    VoidCallback? onMenuTap,
    VoidCallback? onTap,
    ImageProvider Function(String url)? imageProviderBuilder,
  }) {
    final selected = !_isUnselectedMeal(item);
    final meta = decodeMealPinNotes(item.notes);
    return MealTimelineCard(
      title: item.title,
      timeLabel: item.timeLabel,
      rating: meta?.rating,
      priceRange: meta?.priceRange,
      imageUrl: item.externalLink,
      category: item.category.name,
      period: item.period,
      selected: selected,
      onRecommendationsTap: onRecommendationsTap,
      onMenuTap: onMenuTap,
      onTap: onTap,
      imageProviderBuilder: imageProviderBuilder,
    );
  }

  static bool _isUnselectedMeal(ItineraryItemEntity item) {
    if (!categoryIsFood(item.category)) return false;
    final hasPlace = item.providerPlaceId?.trim().isNotEmpty ?? false;
    if (hasPlace) return false;
    return MealTypeAssets.isGenericMealTitle(item.title) ||
        item.latitude == null;
  }

  @override
  Widget build(BuildContext context) {
    return selected ? _buildSelected(context) : _buildUnselected(context);
  }

  Widget _buildUnselected(BuildContext context) {
    final asset = MealTypeAssets.resolve(
      category: category,
      title: title,
      period: period,
    );
    return _MealCardShell(
      onTap: onTap,
      child: Row(
        children: [
          _Thumb(
            asset: asset,
            imageUrl: null,
            imageProviderBuilder: imageProviderBuilder,
          ),
          const SizedBox(width: TwoGoSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TwoGoTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: TwoGoColors.contentPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                GestureDetector(
                  onTap: onRecommendationsTap,
                  child: Text(
                    subtitle ?? 'Ver recomendações',
                    style: TwoGoTypography.labelSmall.copyWith(
                      color: TwoGoColors.contentSecondary,
                      decoration: TextDecoration.underline,
                      decorationColor: TwoGoColors.contentSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _Kebab(onTap: onMenuTap),
        ],
      ),
    );
  }

  Widget _buildSelected(BuildContext context) {
    final asset = MealTypeAssets.resolve(
      category: category,
      title: title,
      period: period,
    );
    final price = priceRange?.trim();
    return _MealCardShell(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Thumb(
            asset: asset,
            imageUrl: imageUrl,
            imageProviderBuilder: imageProviderBuilder,
          ),
          const SizedBox(width: TwoGoSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (timeLabel != null && timeLabel!.trim().isNotEmpty)
                      Expanded(
                        child: Text(
                          timeLabel!,
                          style: TwoGoTypography.labelSmall.copyWith(
                            color: TwoGoColors.contentSecondary,
                          ),
                        ),
                      )
                    else
                      const Spacer(),
                    if (rating != null) ...[
                      const Icon(
                        Icons.star_rounded,
                        size: 16,
                        color: Color(0xFFF5C518),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        rating!.toStringAsFixed(
                          rating! == rating!.roundToDouble() ? 1 : 1,
                        ),
                        style: TwoGoTypography.labelSmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: TwoGoColors.contentPrimary,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: TwoGoTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: TwoGoColors.contentPrimary,
                  ),
                ),
                if (price != null && price.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    price,
                    style: TwoGoTypography.labelSmall.copyWith(
                      color: TwoGoColors.info,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          _Kebab(onTap: onMenuTap),
        ],
      ),
    );
  }
}

class _MealCardShell extends StatelessWidget {
  const _MealCardShell({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TwoGoColors.neutral100,
      borderRadius: BorderRadius.circular(TwoGoRadius.medium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TwoGoRadius.medium),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: TwoGoSpacing.md,
            vertical: TwoGoSpacing.sm + 2,
          ),
          child: child,
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({
    required this.asset,
    this.imageUrl,
    this.imageProviderBuilder,
  });

  final MealTypeAsset asset;
  final String? imageUrl;
  final ImageProvider Function(String url)? imageProviderBuilder;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();
    final hasRemote = url != null && url.isNotEmpty;
    return ClipRRect(
      borderRadius: BorderRadius.circular(TwoGoRadius.small),
      child: SizedBox(
        width: 56,
        height: 56,
        child: hasRemote
            ? Image(
                image: imageProviderBuilder?.call(url) ?? NetworkImage(url),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _assetImage(),
              )
            : _assetImage(),
      ),
    );
  }

  Widget _assetImage() {
    return Image.asset(
      MealTypeAssets.pathFor(asset),
      package: MealTypeAssets.package,
      fit: BoxFit.cover,
    );
  }
}

class _Kebab extends StatelessWidget {
  const _Kebab({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: const Padding(
        padding: EdgeInsets.all(4),
        child: Icon(
          Icons.more_vert_rounded,
          size: 20,
          color: TwoGoColors.neutral600,
        ),
      ),
    );
  }
}

/// Decode Core `2go-meal-pin:` notes metadata written by pin-meal.
class MealPinMeta {
  final String? dish;
  final double? rating;
  final String? priceRange;

  const MealPinMeta({this.dish, this.rating, this.priceRange});
}

MealPinMeta? decodeMealPinNotes(String? notes) {
  if (notes == null || notes.isEmpty) return null;
  const prefix = '2go-meal-pin:';
  if (!notes.startsWith(prefix)) {
    return MealPinMeta(dish: notes);
  }
  try {
    final decoded = jsonDecode(notes.substring(prefix.length));
    if (decoded is! Map) return MealPinMeta(dish: notes);
    final map = Map<String, dynamic>.from(decoded);
    final ratingRaw = map['rating'];
    return MealPinMeta(
      dish: map['dish']?.toString(),
      rating: ratingRaw is num
          ? ratingRaw.toDouble()
          : double.tryParse('$ratingRaw'),
      priceRange: map['priceRange']?.toString(),
    );
  } catch (_) {
    return MealPinMeta(dish: notes);
  }
}

bool isMealItineraryItem(ItineraryItemEntity item) =>
    categoryIsFood(item.category);
