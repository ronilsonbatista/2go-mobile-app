import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

import '../form_course_tokens.dart';

/// Small locality thumb for Places autocomplete rows and selected Onde chips.
///
/// Core `iconUrl` is often a static SVG under `/static/place-icons/*.svg`
/// (Flutter [Image.network] cannot decode SVG). Raster CDN URLs load as photos;
/// SVG place-icons map to a tinted location pin matching Core colors.
class PlaceThumb extends StatelessWidget {
  const PlaceThumb({
    this.iconUrl,
    this.size = 40,
    this.borderRadius,
    super.key,
  });

  final String? iconUrl;
  final double size;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? TwoGoRadius.small;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: size,
        height: size,
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final raw = iconUrl?.trim();
    if (raw == null || raw.isEmpty) {
      return const _PinFallback();
    }

    final url = _normalizeUrl(raw);
    final svgKind = _svgPlaceKind(url);
    if (svgKind != null) {
      return _SvgPlacePin(kind: svgKind);
    }

    if (url.startsWith('http://') || url.startsWith('https://')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        // Spinner (not Material tofu) while the photo loads.
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const ColoredBox(
            color: FormCourseTokens.summaryCard,
            child: Center(
              child: TwoGoLoadingIndicator(size: 16, strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (_, __, ___) => const _PinFallback(),
      );
    }

    return const _PinFallback();
  }

  /// Core sometimes emits `http://` absolute URLs; prefer HTTPS for ATS/cleartext.
  static String _normalizeUrl(String url) {
    if (url.startsWith('http://')) {
      return 'https://${url.substring('http://'.length)}';
    }
    return url;
  }

  static _SvgPlaceKind? _svgPlaceKind(String url) {
    final lower = url.toLowerCase();
    final isSvg = lower.endsWith('.svg') || lower.contains('.svg?');
    final isPlaceIcon = lower.contains('/place-icons/') ||
        lower.contains('/static/place-icons/');
    if (!isSvg && !isPlaceIcon) return null;

    // Match basename only — avoid matching the "place" in "place-icons".
    final file = lower.split('/').last.split('?').first;
    if (file.startsWith('country')) return _SvgPlaceKind.country;
    if (file.startsWith('region')) return _SvgPlaceKind.region;
    if (file.startsWith('place')) return _SvgPlaceKind.place;
    if (file.startsWith('city')) return _SvgPlaceKind.city;
    return isSvg ? _SvgPlaceKind.city : null;
  }
}

enum _SvgPlaceKind { city, country, place, region }

class _SvgPlacePin extends StatelessWidget {
  const _SvgPlacePin({required this.kind});

  final _SvgPlaceKind kind;

  Color get _fill {
    switch (kind) {
      case _SvgPlaceKind.city:
        return const Color(0xFF2563EB);
      case _SvgPlaceKind.country:
        return const Color(0xFF059669);
      case _SvgPlaceKind.place:
        return const Color(0xFFDC2626);
      case _SvgPlaceKind.region:
        return const Color(0xFF7C3AED);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _fill.withValues(alpha: 0.12),
      child: Icon(
        Icons.location_on,
        color: _fill,
        size: 22,
      ),
    );
  }
}

class _PinFallback extends StatelessWidget {
  const _PinFallback();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: FormCourseTokens.summaryCard,
      child: Icon(
        Icons.location_on_outlined,
        size: 18,
        color: FormCourseTokens.label,
      ),
    );
  }
}
