import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

import 'home_asset_image.dart';

/// Destination media: prefer HTTPS Core URL, else local package asset.
class HomeDestinationImage extends StatelessWidget {
  const HomeDestinationImage({
    required this.imageUrl,
    required this.assetPath,
    this.fit = BoxFit.cover,
    super.key,
  });

  final String? imageUrl;
  final String assetPath;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        fit: fit,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }

    if (assetPath.trim().isEmpty) {
      return _fallback();
    }

    return HomeAssetImage(
      assetPath: assetPath,
      fit: fit,
      errorBuilder: (_, __, ___) => _fallback(),
    );
  }

  Widget _fallback() => const ColoredBox(color: TwoGoColors.surfaceSecondary);
}
