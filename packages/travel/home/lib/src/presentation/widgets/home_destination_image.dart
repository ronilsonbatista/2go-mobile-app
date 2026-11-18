import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

/// Destination media from Core only (`imageUrl` / `cardImageUrl`).
///
/// Local package assets are not used for destination photos — product rule:
/// destination images come from the backend.
class HomeDestinationImage extends StatelessWidget {
  const HomeDestinationImage({
    required this.imageUrl,
    this.fit = BoxFit.cover,
    super.key,
  });

  final String? imageUrl;
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
    return _fallback();
  }

  Widget _fallback() => const ColoredBox(color: TwoGoColors.surfaceSecondary);
}
