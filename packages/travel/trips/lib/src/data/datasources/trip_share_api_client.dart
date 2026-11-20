import 'package:dio/dio.dart';
import 'package:twogo_core/twogo_core.dart';
import 'package:twogo_networking/twogo_networking.dart';

import '../../domain/trip_share_models.dart';

/// Dio client for Core trip share / invite / welcome endpoints.
///
/// Expects [ApiEnvelopeInterceptor] (or raw envelope — both supported).
class TripShareApiClient {
  TripShareApiClient(this._dio);

  final Dio _dio;

  Future<TripInviteResult> inviteParticipant(
    String tripId, {
    required String email,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        '/trips/$tripId/participants',
        data: {'email': email.trim().toLowerCase()},
      );
      final json = _asMap(_unwrap(response.data));
      return TripInviteResult.fromJson(json);
    } on DioException catch (e) {
      throw ErrorMapper.mapDioError(e);
    }
  }

  Future<List<TripParticipant>> listParticipants(String tripId) async {
    try {
      final response = await _dio.get<dynamic>('/trips/$tripId/participants');
      final data = _unwrap(response.data);
      final list = _asList(data);
      return list
          .whereType<Map>()
          .map((e) => TripParticipant.fromJson(Map<String, dynamic>.from(e)))
          .toList(growable: false);
    } on DioException catch (e) {
      throw ErrorMapper.mapDioError(e);
    }
  }

  Future<TripParticipant> removeParticipant(
    String tripId,
    String participantId,
  ) async {
    try {
      final response = await _dio.delete<dynamic>(
        '/trips/$tripId/participants/$participantId',
      );
      final json = _asMap(_unwrap(response.data));
      return TripParticipant.fromJson(json);
    } on DioException catch (e) {
      throw ErrorMapper.mapDioError(e);
    }
  }

  Future<TripAcceptInviteResult> acceptInvite({
    required String inviteToken,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        '/trip-invites/accept',
        data: {'inviteToken': inviteToken},
      );
      final json = _asMap(_unwrap(response.data));
      return TripAcceptInviteResult.fromJson(json);
    } on DioException catch (e) {
      throw ErrorMapper.mapDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getSharedTrips() async {
    try {
      final response = await _dio.get<dynamic>('/users/me/shared-trips');
      final data = _unwrap(response.data);
      final list = _asList(data);
      return list
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList(growable: false);
    } on DioException catch (e) {
      throw ErrorMapper.mapDioError(e);
    }
  }

  /// New Core endpoint (PR in flight). Returns [] on 404 until Core merges.
  Future<List<TripWelcomeItem>> listPendingWelcomes() async {
    try {
      final response = await _dio.get<dynamic>(
        '/users/me/trip-welcomes/pending',
      );
      final data = _unwrap(response.data);
      final items = _extractItems(data);
      return items
          .whereType<Map>()
          .map((e) => TripWelcomeItem.fromJson(Map<String, dynamic>.from(e)))
          .where((e) => e.isGuest && e.welcomeSeenAt == null)
          .toList(growable: false);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return const [];
      throw ErrorMapper.mapDioError(e);
    } on AppFailure {
      rethrow;
    }
  }

  /// New Core endpoint (PR in flight).
  Future<TripWelcomeSeenResult> markWelcomeSeen(String tripId) async {
    try {
      final response = await _dio.post<dynamic>(
        '/users/me/trip-welcomes/$tripId/seen',
      );
      final json = _asMap(_unwrap(response.data));
      return TripWelcomeSeenResult.fromJson(json);
    } on DioException catch (e) {
      throw ErrorMapper.mapDioError(e);
    }
  }

  static dynamic _unwrap(dynamic payload) {
    if (payload is Map) {
      final map = Map<String, dynamic>.from(payload);
      if (map.containsKey('data') && map['success'] != false) {
        return map['data'];
      }
    }
    return payload;
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  static List<dynamic> _asList(dynamic value) {
    if (value is List) return value;
    if (value is Map && value['items'] is List) {
      return value['items'] as List<dynamic>;
    }
    return const [];
  }

  static List<dynamic> _extractItems(dynamic value) {
    if (value is List) return value;
    if (value is Map) {
      final items = value['items'];
      if (items is List) return items;
    }
    return const [];
  }
}
