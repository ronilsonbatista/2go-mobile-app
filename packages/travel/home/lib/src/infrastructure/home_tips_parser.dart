import '../domain/models/home_tip.dart';

/// Parses Core tip payloads (`GET /home/tips` or embedded `trip.tips`).
///
/// Always returns at most [maxTips] **per destinationKey** (default 3).
class HomeTipsParser {
  const HomeTipsParser({this.maxTips = defaultMaxTips});

  final int maxTips;

  static const int defaultMaxTips = 3;

  List<HomeTip> parse(dynamic raw, {int? maxPerDestination}) {
    final limit = (maxPerDestination ?? maxTips).clamp(0, defaultMaxTips);
    final items = _extractItems(raw);
    final byKey = <String, List<HomeTip>>{};
    final unkeyed = <HomeTip>[];

    for (var i = 0; i < items.length; i++) {
      final tip = _parseItem(items[i], index: i);
      if (tip == null) continue;
      final key = tip.destinationKey?.trim();
      if (key == null || key.isEmpty) {
        unkeyed.add(tip);
        continue;
      }
      byKey.putIfAbsent(key, () => <HomeTip>[]).add(tip);
    }

    final out = <HomeTip>[];
    for (final entry in byKey.entries) {
      final sorted = [...entry.value]
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      out.addAll(sorted.take(limit));
    }
    if (unkeyed.isNotEmpty) {
      unkeyed.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      out.addAll(unkeyed.take(limit));
    }
    out.sort((a, b) {
      final keyCmp =
          (a.destinationKey ?? '').compareTo(b.destinationKey ?? '');
      if (keyCmp != 0) return keyCmp;
      return a.sortOrder.compareTo(b.sortOrder);
    });
    return List.unmodifiable(out);
  }

  List<dynamic> _extractItems(dynamic raw) {
    if (raw == null) return const [];
    if (raw is List) return raw;
    if (raw is Map) {
      final map = Map<String, dynamic>.from(raw);
      final data = map['data'];
      if (data is List) return data;
      if (data is Map) {
        final nested = Map<String, dynamic>.from(data);
        final items = nested['items'] ?? nested['tips'];
        if (items is List) return items;
      }
      final items = map['items'] ?? map['tips'];
      if (items is List) return items;
    }
    return const [];
  }

  HomeTip? _parseItem(dynamic raw, {required int index}) {
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    final title = (map['title'] as String?)?.trim() ??
        (map['headline'] as String?)?.trim() ??
        '';
    final body = (map['body'] as String?)?.trim() ??
        (map['content'] as String?)?.trim() ??
        (map['text'] as String?)?.trim() ??
        '';
    if (title.isEmpty || body.isEmpty) return null;
    final id = (map['id'] as String?)?.trim();
    final sort = map['sortOrder'];
    return HomeTip(
      id: (id != null && id.isNotEmpty) ? id : 'tip-$index',
      title: title,
      body: body,
      destinationKey: (map['destinationKey'] as String?)?.trim(),
      destinationName: (map['destinationName'] as String?)?.trim(),
      sortOrder: sort is int
          ? sort
          : sort is num
              ? sort.toInt()
              : index,
      source: (map['source'] as String?)?.trim(),
      providerPlaceId: (map['providerPlaceId'] as String?)?.trim(),
    );
  }
}
