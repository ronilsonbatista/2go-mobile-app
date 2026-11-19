import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

import 'home_asset_image.dart';

/// Destination media: Core remote URL first, then local stub asset.
///
/// Staging `GET /home/destinations` may return 0 items until seed; the app
/// falls back to [LocalHomeContentRepository] assets. Prefer remote when
/// present (`imageUrl` / `cardImageUrl`).
class HomeDestinationImage extends StatelessWidget {
  const HomeDestinationImage({
    this.imageUrl,
    this.assetPath,
    this.fit = BoxFit.cover,
    super.key,
  });

  final String? imageUrl;
  final String? assetPath;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        fit: fit,
        errorBuilder: (_, __, ___) => _localOrFallback(),
      );
    }
    return _localOrFallback();
  }

  Widget _localOrFallback() {
    final path = assetPath?.trim();
    if (path != null && path.isNotEmpty) {
      return HomeAssetImage(
        assetPath: path,
        fit: fit,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }
    return _fallback();
  }

  Widget _fallback() => const ColoredBox(color: TwoGoColors.surfaceSecondary);
}
