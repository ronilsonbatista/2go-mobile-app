import 'package:flutter/material.dart';

import '../../infrastructure/local_home_content_repository.dart';

/// Resolves Home destination/avatar assets for both app and package tests.
///
/// App AssetManifest keys are `packages/twogo_home/...` (need [package]).
/// Package-under-test keys are bare `assets/...` (omit [package]).
class HomeAssetImage extends StatelessWidget {
  const HomeAssetImage({
    required this.assetPath,
    this.fit = BoxFit.cover,
    this.errorBuilder,
    super.key,
  });

  final String assetPath;
  final BoxFit fit;
  final ImageErrorWidgetBuilder? errorBuilder;

  static ImageProvider provider(String assetPath) {
    if (LocalHomeContentRepository.usePackageAssetPrefix) {
      return AssetImage(
        assetPath,
        package: LocalHomeContentRepository.assetPackage,
      );
    }
    return AssetImage(assetPath);
  }

  @override
  Widget build(BuildContext context) {
    return Image(
      image: provider(assetPath),
      fit: fit,
      errorBuilder: errorBuilder,
    );
  }
}
