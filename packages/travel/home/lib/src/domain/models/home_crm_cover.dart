import 'home_destination.dart';
import 'home_trip_summary.dart';
import '../../infrastructure/local_home_content_repository.dart';

/// Resolved hero for the Home CRM "Próxima viagem" card.
///
/// Same idea as Day-1 [resolvePreviewCover]: prefer Core/trip URL, then
/// Home destinations catalog (remote or local asset), then local stub catalog.
class HomeCrmCover {
  const HomeCrmCover({
    this.networkUrl,
    this.assetPath,
  });

  final String? networkUrl;
  final String? assetPath;

  bool get hasImage {
    final url = networkUrl?.trim();
    if (url != null && url.isNotEmpty) return true;
    final asset = assetPath?.trim();
    return asset != null && asset.isNotEmpty;
  }
}

/// Resolves CRM trip cover without inventing APIs.
HomeCrmCover resolveHomeCrmCover({
  required HomeTripSummary trip,
  List<HomeDestination> destinations = const [],
}) {
  String? networkUrl = _nonEmpty(trip.coverImageUrl);
  String? assetPath;

  final names = trip.destinationNames;
  final primaryName = names.isNotEmpty ? names.first : null;

  // Match Home destinations strip / API catalog (same path Day-1 uses via
  // Home catalog entries).
  final match = _matchDestination(destinations, primaryName);
  if (match != null) {
    final remote = match.resolvedHeroUrl ?? match.resolvedCardUrl;
    if (networkUrl == null || networkUrl.isEmpty) {
      networkUrl = _nonEmpty(remote);
    }
    if (match.hasLocalHero) {
      assetPath = match.heroAssetPath;
    } else if (match.hasLocalCard) {
      assetPath = match.cardAssetPath;
    }
  }

  // Local stub catalog (includes Tóquio → assets/destinations/toquio.jpg).
  if (assetPath == null || assetPath.isEmpty) {
    final local = _matchDestination(
      LocalHomeContentRepository.catalog,
      primaryName,
    );
    if (local != null) {
      if ((networkUrl == null || networkUrl.isEmpty) &&
          local.resolvedHeroUrl != null) {
        networkUrl = local.resolvedHeroUrl;
      }
      if (local.hasLocalHero) {
        assetPath = local.heroAssetPath;
      } else if (local.hasLocalCard) {
        assetPath = local.cardAssetPath;
      }
    }
  }

  return HomeCrmCover(networkUrl: networkUrl, assetPath: assetPath);
}

HomeDestination? _matchDestination(
  List<HomeDestination> destinations,
  String? name,
) {
  final needle = _normalize(name);
  if (needle == null) return null;

  for (final d in destinations) {
    if (_normalize(d.name) == needle || _normalize(d.id) == needle) {
      return d;
    }
  }

  // Tokyo / Tóquio / Tokio aliases (E2E trip uses "Tokyo").
  final aliases = _aliasesFor(needle);
  for (final d in destinations) {
    final key = _normalize(d.name);
    final id = _normalize(d.id);
    if (aliases.contains(key) || aliases.contains(id)) return d;
  }

  for (final d in destinations) {
    final key = _normalize(d.name);
    if (key != null &&
        (needle.startsWith('$key ') ||
            needle.startsWith('$key-') ||
            key.startsWith('$needle ') ||
            key.startsWith('$needle-'))) {
      return d;
    }
  }
  return null;
}

Set<String> _aliasesFor(String key) {
  const groups = <List<String>>[
    ['tokyo', 'toquio', 'tokio', 'tóquio'],
    ['roma', 'rome'],
    ['nova york', 'nova-york', 'new york', 'new-york'],
    ['rio de janeiro', 'rio'],
    ['capadocia', 'cappadocia'],
    ['amsterdam', 'amsterda'],
    ['lisboa', 'lisbon'],
    ['londres', 'london'],
  ];
  for (final group in groups) {
    final normalized = group.map(_normalize).whereType<String>().toSet();
    if (normalized.contains(key)) return normalized;
  }
  return {key};
}

String? _nonEmpty(String? value) {
  final text = value?.trim();
  if (text == null || text.isEmpty) return null;
  return text;
}

String? _normalize(String? raw) {
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
