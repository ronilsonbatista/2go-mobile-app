import 'package:dio/dio.dart';
import '../models/create_planning_session_dto.dart';
import '../models/generation_status_response_dto.dart';
import '../models/planning_session_response_dto.dart';
import '../models/update_planning_session_dto.dart';

class PlanningApiClient {
  final Dio _dio;

  PlanningApiClient(this._dio);

  Future<CreatePlanningSessionResponseDto> createSession(
    CreatePlanningSessionDto dto,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/planning-sessions',
      data: dto.toJson(),
    );
    return CreatePlanningSessionResponseDto.fromJson(response.data ?? {});
  }

  Future<PlanningSessionResponseDto> getSession(
    String id, {
    required String guestToken,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/planning-sessions/$id',
      options: Options(headers: {'X-Guest-Token': guestToken}),
    );
    return PlanningSessionResponseDto.fromJson(response.data ?? {});
  }

  Future<PlanningSessionResponseDto> updateProgress(
    String id,
    UpdatePlanningSessionDto dto, {
    required String guestToken,
  }) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/planning-sessions/$id',
      data: dto.toJson(),
      options: Options(headers: {'X-Guest-Token': guestToken}),
    );
    return PlanningSessionResponseDto.fromJson(response.data ?? {});
  }

  Future<PlanningSessionResponseDto> finalizeQuestionnaire(
    String id, {
    required String guestToken,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/planning-sessions/$id/finalize',
      options: Options(headers: {'X-Guest-Token': guestToken}),
    );
    return PlanningSessionResponseDto.fromJson(response.data ?? {});
  }

  Future<GenerationStatusResponseDto> startGeneration(
    String id, {
    required String guestToken,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/planning-sessions/$id/generate',
      options: Options(headers: {'X-Guest-Token': guestToken}),
    );
    return GenerationStatusResponseDto.fromJson(response.data ?? {});
  }

  Future<GenerationStatusResponseDto> getGenerationStatus(
    String id, {
    required String guestToken,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/planning-sessions/$id/generation-status',
      options: Options(headers: {'X-Guest-Token': guestToken}),
    );
    return GenerationStatusResponseDto.fromJson(response.data ?? {});
  }
}
