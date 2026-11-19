import 'package:flutter/material.dart';

import '../place_details_tokens.dart';

class PlacePhotoCarousel extends StatefulWidget {
  final List<String> photoUrls;
  final double height;
  final ImageProvider Function(String url)? imageProviderBuilder;

  const PlacePhotoCarousel({
    super.key,
    required this.photoUrls,
    this.height = PlaceDetailsTokens.heroHeight,
    this.imageProviderBuilder,
  });

  @override
  State<PlacePhotoCarousel> createState() => _PlacePhotoCarouselState();
}

class _PlacePhotoCarouselState extends State<PlacePhotoCarousel> {
  var _index = 0;

  @override
  Widget build(BuildContext context) {
    final urls = widget.photoUrls;
    if (urls.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(PlaceDetailsTokens.heroRadius),
        child: Container(
          height: widget.height,
          width: double.infinity,
          color: PlaceDetailsTokens.chipSurface,
          alignment: Alignment.center,
          child: const Icon(
            Icons.image_outlined,
            size: 48,
            color: PlaceDetailsTokens.muted,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(PlaceDetailsTokens.heroRadius),
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              itemCount: urls.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, i) {
                final url = urls[i];
                final provider = widget.imageProviderBuilder != null
                    ? widget.imageProviderBuilder!(url)
                    : NetworkImage(url);
                return Image(
                  image: provider,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: PlaceDetailsTokens.chipSurface,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.broken_image_outlined,
                      color: PlaceDetailsTokens.muted,
                    ),
                  ),
                );
              },
            ),
            if (urls.length > 1)
              Positioned(
                left: 0,
                right: 0,
                bottom: 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(urls.length.clamp(0, 8), (i) {
                    final active = i == _index;
                    return Container(
                      width: 7,
                      height: 7,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: active
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.45),
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
