import 'package:flutter/painting.dart';

import '../../presentation/wizard/widgets/destination_thumb_catalog.dart';
import 'planning_preview.dart';

/// One row from Home / catalog used when Core preview cover fields are empty.
class PreviewCoverCatalogEntry {
  const PreviewCoverCatalogEntry({
    required this.name,
    this.providerPlaceId,
    this.imageUrl,
    this.assetPath,
    this.assetPackage,
  });

  final String name;
  final String? providerPlaceId;
  final String? imageUrl;
  final String? assetPath;
  final String? assetPackage;
}

/// Resolved hero photo for Day-1 preview (network URL and/or packaged asset).
class PreviewCoverResolution {
  const PreviewCoverResolution({
    this.networkUrl,
    this.assetPath,
    this.assetPackage,
  });

  final String? networkUrl;
  final String? assetPath;
  final String? assetPackage;

  bool get hasImage {
    final url = networkUrl?.trim();
    if (url != null && url.isNotEmpty) return true;
    final asset = assetPath?.trim();
    return asset != null && asset.isNotEmpty;
  }

  ImageProvider? toImageProvider() {
    final url = networkUrl?.trim();
    if (url != null && url.isNotEmpty) return NetworkImage(url);
    final asset = assetPath?.trim();
    if (asset == null || asset.isEmpty) return null;
    final pkg = assetPackage?.trim();
    return AssetImage(asset, package: (pkg == null || pkg.isEmpty) ? null : pkg);
  }
}

/// Resolves Day-1 hero cover without inventing Core APIs.
///
/// Order: summary `coverImageUrl` → first destination `coverImage` →
/// Home/catalog match by `providerPlaceId` / `placeId` / name →
/// packaged [DestinationThumbCatalog] by destination name.
PreviewCoverResolution? resolvePreviewCover({
  required PlanningPreviewSummary summary,
  List<PreviewCoverCatalogEntry> catalog = const [],
}) {
  final fromPayload = summary.resolvedCoverImageUrl;
  if (fromPayload != null && fromPayload.isNotEmpty) {
    return PreviewCoverResolution(networkUrl: fromPayload);
  }

  final first = _firstDestinationMap(summary);
  final placeId = _nonEmpty(
        first?['providerPlaceId']?.toString(),
      ) ??
      _nonEmpty(first?['placeId']?.toString());
  final name = _nonEmpty(first?['name']?.toString());

  if (catalog.isNotEmpty) {
    PreviewCoverCatalogEntry? match;
    if (placeId != null) {
      for (final entry in catalog) {
        final id = entry.providerPlaceId?.trim();
        if (id != null && id.isNotEmpty && id == placeId) {
          match = entry;
          break;
        }
      }
    }
    if (match == null && name != null) {
      final needle = _normalizeName(name);
      for (final entry in catalog) {
        if (_normalizeName(entry.name) == needle) {
          match = entry;
          break;
        }
      }
      if (match == null) {
        for (final entry in catalog) {
          final entryKey = _normalizeName(entry.name);
          if (entryKey != null &&
              needle != null &&
              (needle.startsWith('$entryKey ') ||
                  needle.startsWith('$entryKey-') ||
                  entryKey.startsWith('$needle ') ||
                  entryKey.startsWith('$needle-'))) {
            match = entry;
            break;
          }
        }
      }
    }
    if (match != null) {
      final url = match.imageUrl?.trim();
      if (url != null && url.isNotEmpty) {
        return PreviewCoverResolution(networkUrl: url);
      }
      final asset = match.assetPath?.trim();
      if (asset != null && asset.isNotEmpty) {
        return PreviewCoverResolution(
          assetPath: asset,
          assetPackage: match.assetPackage,
        );
      }
    }
  }

  final thumb = DestinationThumbCatalog.assetForName(name);
  if (thumb != null) {
    return PreviewCoverResolution(
      assetPath: thumb,
      assetPackage: DestinationThumbCatalog.package,
    );
  }
  return null;
}

Map<dynamic, dynamic>? _firstDestinationMap(PlanningPreviewSummary summary) {
  if (summary.destinations.isEmpty) return null;
  final first = summary.destinations[0];
  if (first is Map) return first;
  return null;
}

String? _nonEmpty(String? value) {
  final text = value?.trim();
  if (text == null || text.isEmpty) return null;
  return text;
}

String? _normalizeName(String? raw) {
  if (raw == null) return null;
  var s = raw.trim().toLowerCase();
  if (s.isEmpty) return null;
  const accents = {
    'á': 'a',
    'à': 'a',
    'ã': 'a',
    'â': 'a',
    'é': 'e',
    'ê': 'e',
    'í': 'i',
    'ó': 'o',
    'ô': 'o',
    'õ': 'o',
    'ú': 'u',
    'ü': 'u',
    'ç': 'c',
  };
  final buf = StringBuffer();
  for (final rune in s.runes) {
    final ch = String.fromCharCode(rune);
    buf.write(accents[ch] ?? ch);
  }
  s = buf.toString().replaceAll(RegExp(r'[^a-z0-9\s-]'), ' ');
  s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
  return s.isEmpty ? null : s;
}
