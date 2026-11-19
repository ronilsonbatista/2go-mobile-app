import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

import '../place_details_tokens.dart';

/// Mini-map card with pin + address (opens Maps via [onOpenMaps]).
class PlaceMapPreview extends StatelessWidget {
  final String? address;
  final double? latitude;
  final double? longitude;
  final VoidCallback? onOpenMaps;
  final ImageProvider Function(String url)? imageProviderBuilder;

  const PlaceMapPreview({
    super.key,
    this.address,
    this.latitude,
    this.longitude,
    this.onOpenMaps,
    this.imageProviderBuilder,
  });

  String? get _staticMapUrl {
    if (latitude == null || longitude == null) return null;
    // OSM static map — no API key; used as visual anchor only.
    return 'https://staticmap.openstreetmap.de/staticmap.php'
        '?center=$latitude,$longitude'
        '&zoom=15&size=600x300&maptype=mapnik'
        '&markers=$latitude,$longitude,red-pushpin';
  }

  @override
  Widget build(BuildContext context) {
    if (address == null && latitude == null) return const SizedBox.shrink();

    final mapUrl = _staticMapUrl;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpenMaps,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: PlaceDetailsTokens.cardBorder),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: PlaceDetailsTokens.mapHeight,
                  child: mapUrl == null
                      ? Container(
                          color: PlaceDetailsTokens.chipSurface,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.map_outlined,
                            color: PlaceDetailsTokens.muted,
                            size: 40,
                          ),
                        )
                      : Stack(
                          fit: StackFit.expand,
                          children: [
                            Image(
                              image: imageProviderBuilder != null
                                  ? imageProviderBuilder!(mapUrl)
                                  : NetworkImage(mapUrl),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: const Color(0xFFE8EEF2),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.map_outlined,
                                  color: PlaceDetailsTokens.muted,
                                  size: 40,
                                ),
                              ),
                            ),
                            const Center(
                              child: Icon(
                                Icons.location_on,
                                color: PlaceDetailsTokens.mapPin,
                                size: 36,
                              ),
                            ),
                          ],
                        ),
                ),
                if (address != null && address!.trim().isNotEmpty)
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 18,
                          color: PlaceDetailsTokens.mapPin,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            address!,
                            style: TwoGoTypography.bodySmall.copyWith(
                              color: PlaceDetailsTokens.ink,
                            ),
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
    );
  }
}
