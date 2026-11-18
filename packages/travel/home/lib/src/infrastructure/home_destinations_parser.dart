import '../domain/models/home_destination.dart';

/// Parses Core `GET /home/destinations` payloads.
///
/// Accepts either the raw envelope `{ success, data, timestamp }` (reads
/// `data.items`) or the unwrapped `data` map / list that Dio already returns
/// after [ApiEnvelopeInterceptor].
class HomeDestinationsParser {
  const HomeDestinationsParser();

  /// Default Core clamp when the client omits `?limit=`.
  static const int defaultLimit = 50;

  /// Clamp query `limit` to Core's documented `1..50` range.
  static int clampLimit(int? limit) {
    if (limit == null) return defaultLimit;
    if (limit < 1) return 1;
    if (limit > 50) return 50;
    return limit;
  }

  List<HomeDestination> parse(dynamic payload, {int? limit}) {
    final items = _extractItems(payload);
    final max = clampLimit(limit);

    final destinations = <HomeDestination>[];
    for (final raw in items) {
      if (raw is! Map) continue;
      final mapped = _mapItem(Map<String, dynamic>.from(raw));
      if (mapped == null) continue;
      if (!mapped.active) continue;
      destinations.add(mapped);
    }

    destinations.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    if (destinations.length <= max) return destinations;
    return destinations.take(max).toList(growable: false);
  }

  List<dynamic> _extractItems(dynamic payload) {
    if (payload == null) return const [];

    if (payload is List) return payload;

    if (payload is Map) {
      final map = Map<String, dynamic>.from(payload);

      // Raw envelope: { success, data: { items: [...] }, timestamp }
      if (map.containsKey('data')) {
        final data = map['data'];
        if (data is Map) {
          final nested = Map<String, dynamic>.from(data);
          final items = nested['items'];
          if (items is List) return items;
        }
        if (data is List) return data;
      }

      // Unwrapped data (post-interceptor): { items: [...] }
      final items = map['items'];
      if (items is List) return items;
    }

    return const [];
  }

  HomeDestination? _mapItem(Map<String, dynamic> json) {
    final id = _string(json['id']) ?? _string(json['slug']);
    final name = _string(json['name']);
    final imageUrl = _string(json['imageUrl']);
    // Core excludes Home items without Google Places id — mirror that here.
    // Do not invent providerPlaceId from slug/`id`.
    final providerPlaceId = _string(json['providerPlaceId']);
    if (id == null ||
        name == null ||
        imageUrl == null ||
        providerPlaceId == null) {
      return null;
    }

    final country = _string(json['country']) ?? '';
    final cardImageUrl = _string(json['cardImageUrl']);
    final sortOrder = _int(json['sortOrder']) ?? 0;
    final active = _bool(json['active']) ?? true;

    return HomeDestination(
      id: id,
      name: name,
      country: country,
      imageUrl: imageUrl,
      cardImageUrl: cardImageUrl,
      providerPlaceId: providerPlaceId,
      sortOrder: sortOrder,
      active: active,
    );
  }

  String? _string(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  int? _int(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  bool? _bool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1') return true;
      if (normalized == 'false' || normalized == '0') return false;
    }
    return null;
  }
}
