/// Curated monument / city thumbs for Onde + Revisao until Core returns
/// raster photos on every `iconUrl` / `coverImage`.
///
/// Maps normalized destination names → packaged JPEG under
/// `assets/destination_thumbs/` (Roma→Colosseum, Paris→tower, Tóquio, …).
abstract final class DestinationThumbCatalog {
  static const package = 'twogo_planning';

  static const Map<String, String> _byKey = {
    'roma': 'assets/destination_thumbs/roma.jpg',
    'rome': 'assets/destination_thumbs/roma.jpg',
    'paris': 'assets/destination_thumbs/paris.jpg',
    'toquio': 'assets/destination_thumbs/toquio.jpg',
    'tokyo': 'assets/destination_thumbs/toquio.jpg',
    'tokio': 'assets/destination_thumbs/toquio.jpg',
    'nova york': 'assets/destination_thumbs/nova-york.jpg',
    'nova-york': 'assets/destination_thumbs/nova-york.jpg',
    'new york': 'assets/destination_thumbs/nova-york.jpg',
    'lisboa': 'assets/destination_thumbs/lisboa.jpg',
    'lisbon': 'assets/destination_thumbs/lisboa.jpg',
    'londres': 'assets/destination_thumbs/londres.jpg',
    'london': 'assets/destination_thumbs/londres.jpg',
    'barcelona': 'assets/destination_thumbs/barcelona.jpg',
    'amsterdam': 'assets/destination_thumbs/amsterdam.jpg',
    'amsterda': 'assets/destination_thumbs/amsterdam.jpg',
    'capadocia': 'assets/destination_thumbs/capadocia.jpg',
    'cappadocia': 'assets/destination_thumbs/capadocia.jpg',
    'rio de janeiro': 'assets/destination_thumbs/rio-de-janeiro.jpg',
    'rio': 'assets/destination_thumbs/rio-de-janeiro.jpg',
  };

  /// Returns a package-relative asset path, or null when unknown.
  static String? assetForName(String? name) {
    final key = _normalize(name);
    if (key == null) return null;
    final exact = _byKey[key];
    if (exact != null) return exact;
    // Prefix match: "Roma Centro" → roma
    for (final entry in _byKey.entries) {
      if (key.startsWith('${entry.key} ') || key.startsWith('${entry.key}-')) {
        return entry.value;
      }
    }
    return null;
  }

  static String? _normalize(String? raw) {
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
}
