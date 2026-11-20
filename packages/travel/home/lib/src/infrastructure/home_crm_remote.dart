import 'package:dio/dio.dart';

import '../domain/models/home_crm_snapshot.dart';
import '../domain/models/home_tip.dart';
import 'home_tips_parser.dart';
import 'home_trip_summary_parser.dart';

/// Loads paid-trip Home CRM from Core:
/// - `GET /home/trip` (Bearer) — next unlocked paid trip or `trip: null`
/// - `GET /home/tips` (Bearer) — max 3 per destination (fallback if trip tips empty)
class HomeCrmRemote {
  HomeCrmRemote({
    required Dio dio,
    this.tripPath = '/home/trip',
    this.tipsPath = '/home/tips',
    HomeTripSummaryParser tripParser = const HomeTripSummaryParser(),
    HomeTipsParser tipsParser = const HomeTipsParser(),
  }) : _dio = dio,
       _tripParser = tripParser,
       _tipsParser = tipsParser;

  final Dio _dio;
  final String tripPath;
  final String tipsPath;
  final HomeTripSummaryParser _tripParser;
  final HomeTipsParser _tipsParser;

  Future<HomeCrmSnapshot> fetch({required bool isAuthenticated}) async {
    if (!isAuthenticated) return HomeCrmSnapshot.empty;

    try {
      final response = await _dio.get<dynamic>(tripPath);
      final trip = _tripParser.parseHomeTripResponse(response.data);
      if (trip == null) return HomeCrmSnapshot.empty;

      var tips = trip.tips;
      if (tips.isEmpty) {
        tips = await _fetchTipsForTrip(trip.destinationKeys, trip.destinationNames);
      }

      return HomeCrmSnapshot(trip: trip, tips: tips);
    } on DioException catch (e) {
      // 401/403 → treat as no CRM (discovery). Other errors bubble to fallback.
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        return HomeCrmSnapshot.empty;
      }
      // Endpoint not deployed yet (pre-merge staging): soft empty.
      if (e.response?.statusCode == 404) {
        return HomeCrmSnapshot.empty;
      }
      rethrow;
    }
  }

  Future<List<HomeTip>> _fetchTipsForTrip(
    List<String> keys,
    List<String> names,
  ) async {
    final out = <HomeTip>[];
    final seen = <String>{};

    Future<void> load({String? key, String? name}) async {
      try {
        final query = <String, dynamic>{
          'limit': HomeTipsParser.defaultMaxTips,
        };
        if (key != null && key.isNotEmpty) {
          query['destinationKey'] = key;
        } else if (name != null && name.isNotEmpty) {
          query['destination'] = name;
        } else {
          return;
        }
        final response = await _dio.get<dynamic>(
          tipsPath,
          queryParameters: query,
        );
        for (final tip in _tipsParser.parse(response.data)) {
          if (seen.add(tip.id)) out.add(tip);
        }
      } catch (_) {
        // Soft-fail per destination — CRM still shows the trip card.
      }
    }

    if (keys.isNotEmpty) {
      for (final key in keys) {
        await load(key: key);
      }
    } else {
      for (final name in names) {
        await load(name: name);
      }
    }
    return List.unmodifiable(out);
  }
}
