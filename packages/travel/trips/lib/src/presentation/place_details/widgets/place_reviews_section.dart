import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

import '../../../domain/paid_trip_controls.dart';
import '../place_details_tokens.dart';

class PlaceReviewsSection extends StatelessWidget {
  final List<PlaceReview> reviews;
  final VoidCallback? onMoreReviews;
  final ImageProvider Function(String url)? imageProviderBuilder;

  const PlaceReviewsSection({
    super.key,
    required this.reviews,
    this.onMoreReviews,
    this.imageProviderBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Avaliações',
          style: TwoGoTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: PlaceDetailsTokens.ink,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 168,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: reviews.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return _ReviewCard(
                review: reviews[index],
                imageProviderBuilder: imageProviderBuilder,
              );
            },
          ),
        ),
        if (onMoreReviews != null) ...[
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: onMoreReviews,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Mais avaliações',
                    style: TwoGoTypography.labelLarge.copyWith(
                      color: PlaceDetailsTokens.ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.north_east,
                    size: 16,
                    color: PlaceDetailsTokens.lime,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final PlaceReview review;
  final ImageProvider Function(String url)? imageProviderBuilder;

  const _ReviewCard({required this.review, this.imageProviderBuilder});

  @override
  Widget build(BuildContext context) {
    final stars = (review.rating ?? 0).round().clamp(0, 5);
    final photo = review.authorPhotoUri;

    return Container(
      width: PlaceDetailsTokens.reviewCardWidth,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PlaceDetailsTokens.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: PlaceDetailsTokens.chipSurface,
                backgroundImage: photo != null && photo.isNotEmpty
                    ? (imageProviderBuilder != null
                          ? imageProviderBuilder!(photo)
                          : NetworkImage(photo))
                    : null,
                child: photo == null || photo.isEmpty
                    ? Text(
                        _initial(review.authorName),
                        style: TwoGoTypography.labelLarge,
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  review.authorName ?? 'Viajante',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TwoGoTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (i) {
              return Icon(
                i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                size: 16,
                color: i < stars
                    ? PlaceDetailsTokens.star
                    : PlaceDetailsTokens.muted,
              );
            }),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              review.text ?? '',
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: TwoGoTypography.bodySmall.copyWith(
                color: PlaceDetailsTokens.muted,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _initial(String? name) {
  final text = name?.trim();
  if (text == null || text.isEmpty) return '?';
  return text.substring(0, 1).toUpperCase();
}
