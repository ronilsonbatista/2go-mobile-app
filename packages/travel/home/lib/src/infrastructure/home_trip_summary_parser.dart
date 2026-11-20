import '../domain/models/home_tip.dart';
import '../domain/models/home_trip_day.dart';
import '../domain/models/home_trip_summary.dart';
import 'home_tips_parser.dart';

/// Maps `GET /home/trip` → [HomeTripSummary].
///
/// Reads `data.trip` (nullable). Destination names come only from Core fields.
class HomeTripSummaryParser {
  const HomeTripSummaryParser({
    this.tipsParser = const HomeTipsParser(),
  });

  final HomeTipsParser tipsParser;

  /// Returns null when Core sends `trip: null` (discovery Home).
  HomeTripSummary? parseHomeTripResponse(dynamic raw) {
    final tripRaw = _extractTrip(raw);
    if (tripRaw == null) return null;
    return parseTripObject(tripRaw);
  }

  HomeTripSummary? parseTripObject(Map<String, dynamic> map) {
    final id = (map['id'] as String?)?.trim() ?? '';
    if (id.isEmpty) return null;

    final destinations = _parseDestinations(map['destinations']);
    final names = destinations.map((d) => d.name).toList(growable: false);
    final keys =
        destinations.map((d) => d.key).where((k) => k.isNotEmpty).toList();

    // Fallback: singular destination string only if destinations[] empty.
    final fallbackName = (map['destination'] as String?)?.trim() ?? '';
    final resolvedNames = names.isNotEmpty
        ? names
        : (fallbackName.isNotEmpty ? [fallbackName] : <String>[]);
    if (resolvedNames.isEmpty) return null;

    final cover = (map['coverImageUrl'] as String?)?.trim() ??
        (map['coverImage'] as String?)?.trim();
    final start = _parseDate(map['startDate']);
    final end = _parseDate(map['endDate']);
    final arrival = _parseDate(map['arrivalDateTime']);
    final days = _parseDays(map['days']);
    final tips = tipsParser.parse(map['tips']);

    return HomeTripSummary(
      id: id,
      title: (map['title'] as String?)?.trim(),
      destinationNames: resolvedNames,
      destinationKeys: keys.isNotEmpty ? keys : const [],
      coverImageUrl: (cover != null && cover.isNotEmpty) ? cover : null,
      startDate: start,
      endDate: end,
      arrivalDateTime: arrival,
      days: days,
      tips: tips,
      premiumUnlocked: map['premiumUnlocked'] == true,
      status: (map['status'] as String?)?.trim(),
    );
  }

  Map<String, dynamic>? _extractTrip(dynamic raw) {
    if (raw == null) return null;
    if (raw is Map) {
      final map = Map<String, dynamic>.from(raw);
      // Envelope: { success, data: { trip } } or already { trip }
      final data = map['data'];
      if (data is Map) {
        final nested = Map<String, dynamic>.from(data);
        final trip = nested['trip'];
        if (trip == null) return null;
        if (trip is Map) return Map<String, dynamic>.from(trip);
      }
      if (map.containsKey('trip')) {
        final trip = map['trip'];
        if (trip == null) return null;
        if (trip is Map) return Map<String, dynamic>.from(trip);
      }
      // Bare trip object (tests / mocks).
      if (map['id'] != null &&
          (map['destinations'] != null || map['destination'] != null)) {
        return map;
      }
    }
    return null;
  }

  List<_Dest> _parseDestinations(dynamic raw) {
    if (raw is! List) return const [];
    final out = <_Dest>[];
    for (final item in raw) {
      if (item is String) {
        final t = item.trim();
        if (t.isNotEmpty) out.add(_Dest(name: t, key: ''));
        continue;
      }
      if (item is! Map) continue;
      final m = Map<String, dynamic>.from(item);
      final name = (m['name'] as String?)?.trim() ??
          (m['city'] as String?)?.trim() ??
          '';
      if (name.isEmpty) continue;
      final key = (m['destinationKey'] as String?)?.trim() ?? '';
      out.add(_Dest(name: name, key: key));
    }
    return out;
  }

  List<HomeTripDay> _parseDays(dynamic raw) {
    if (raw is! List) return const [];
    final out = <HomeTripDay>[];
    for (var i = 0; i < raw.length; i++) {
      final item = raw[i];
      if (item is! Map) continue;
      final m = Map<String, dynamic>.from(item);
      final id = (m['id'] as String?)?.trim() ?? 'day-$i';
      final dayNumber = m['dayNumber'] is int
          ? m['dayNumber'] as int
          : m['dayNumber'] is num
              ? (m['dayNumber'] as num).toInt()
              : i + 1;
      final itemCount = m['itemCount'] is int
          ? m['itemCount'] as int
          : m['itemCount'] is num
              ? (m['itemCount'] as num).toInt()
              : 0;
      out.add(
        HomeTripDay(
          id: id,
          dayNumber: dayNumber,
          date: _parseDate(m['date']),
          destination: (m['destination'] as String?)?.trim(),
          title: (m['title'] as String?)?.trim(),
          itemCount: itemCount,
        ),
      );
    }
    out.sort((a, b) => a.dayNumber.compareTo(b.dayNumber));
    return List.unmodifiable(out);
  }

  DateTime? _parseDate(dynamic raw) {
    if (raw is DateTime) return raw;
    if (raw is! String || raw.trim().isEmpty) return null;
    return DateTime.tryParse(raw.trim());
  }
}

class _Dest {
  const _Dest({required this.name, required this.key});
  final String name;
  final String key;
}

/// Re-export tip type for callers that only import this parser.
typedef HomeTripTips = List<HomeTip>;
