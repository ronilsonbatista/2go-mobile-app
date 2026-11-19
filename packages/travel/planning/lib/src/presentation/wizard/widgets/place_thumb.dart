import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

import '../form_course_tokens.dart';
import 'destination_thumb_catalog.dart';

/// Small locality thumb for Places autocomplete rows and selected Onde chips.
///
/// Priority:
/// 1. Raster `http(s)` [iconUrl] / cover (Core CDN photo)
/// 2. Curated monument stub by [placeName] (Roma→Colosseum, Paris→tower, …)
/// 3. Core SVG place-icons → tinted pin (last resort, never tofu [?])
class PlaceThumb extends StatelessWidget {
  const PlaceThumb({
    this.iconUrl,
    this.placeName,
    this.size = 40,
    this.borderRadius,
    super.key,
  });

  final String? iconUrl;
  final String? placeName;
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
    if (raw != null && raw.isNotEmpty) {
      final url = _normalizeUrl(raw);
      final svgKind = _svgPlaceKind(url);
      if (svgKind == null &&
          (url.startsWith('http://') || url.startsWith('https://'))) {
        return Image.network(
          url,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return const ColoredBox(
              color: FormCourseTokens.summaryCard,
              child: Center(
                child: TwoGoLoadingIndicator(size: 16, strokeWidth: 2),
              ),
            );
          },
          errorBuilder: (_, __, ___) => _curatedOrPin(),
        );
      }
      // SVG / place-icons — prefer curated monument photo over generic pin.
      return _curatedOrPin(svgKind: svgKind);
    }

    return _curatedOrPin();
  }

  Widget _curatedOrPin({_SvgPlaceKind? svgKind}) {
    final asset = DestinationThumbCatalog.assetForName(placeName);
    if (asset != null) {
      return Image.asset(
        asset,
        package: DestinationThumbCatalog.package,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            svgKind != null ? _SvgPlacePin(kind: svgKind) : const _PinFallback(),
      );
    }
    if (svgKind != null) return _SvgPlacePin(kind: svgKind);
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
