import 'planning_activity_window_dto.dart';
import 'planning_destination_dto.dart';
import 'planning_travelers_dto.dart';

class PlanningSessionResponseDto {
  final String id;
  final String status;
  final int answersVersion;
  final int currentStep;
  final List<PlanningDestinationDto>? destinations;
  final PlanningTravelersDto? travelers;
  final List<String>? interests;
  final PlanningActivityWindowDto? activityHours;
  final String? travelStyle;
  final String? budgetLevel;
  final String expiresAt;
  final String createdAt;
  final String updatedAt;

  const PlanningSessionResponseDto({
    required this.id,
    required this.status,
    required this.answersVersion,
    required this.currentStep,
    this.destinations,
    this.travelers,
    this.interests,
    this.activityHours,
    this.travelStyle,
    this.budgetLevel,
    required this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PlanningSessionResponseDto.fromJson(Map<String, dynamic> json) {
    return PlanningSessionResponseDto(
      id: json['id'] as String,
      status: json['status'] as String,
      answersVersion: json['answersVersion'] as int? ?? 1,
      currentStep: json['currentStep'] as int? ?? 1,
      destinations: (json['destinations'] as List<dynamic>?)
          ?.map(
            (e) => PlanningDestinationDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      travelers: json['travelers'] != null
          ? PlanningTravelersDto.fromJson(
              json['travelers'] as Map<String, dynamic>,
            )
          : null,
      interests: (json['interests'] as List<dynamic>?)?.cast<String>(),
      activityHours: json['activityHours'] != null
          ? PlanningActivityWindowDto.fromJson(
              json['activityHours'] as Map<String, dynamic>,
            )
          : null,
      travelStyle: json['travelStyle'] as String?,
      budgetLevel: json['budgetLevel'] as String?,
      expiresAt: json['expiresAt'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }
}

class CreatePlanningSessionResponseDto extends PlanningSessionResponseDto {
  final String guestToken;

  const CreatePlanningSessionResponseDto({
    required super.id,
    required super.status,
    required super.answersVersion,
    required super.currentStep,
    super.destinations,
    super.travelers,
    super.interests,
    super.activityHours,
    super.travelStyle,
    super.budgetLevel,
    required super.expiresAt,
    required super.createdAt,
    required super.updatedAt,
    required this.guestToken,
  });

  factory CreatePlanningSessionResponseDto.fromJson(Map<String, dynamic> json) {
    return CreatePlanningSessionResponseDto(
      id: json['id'] as String,
      status: json['status'] as String,
      answersVersion: json['answersVersion'] as int? ?? 1,
      currentStep: json['currentStep'] as int? ?? 1,
      destinations: (json['destinations'] as List<dynamic>?)
          ?.map(
            (e) => PlanningDestinationDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      travelers: json['travelers'] != null
          ? PlanningTravelersDto.fromJson(
              json['travelers'] as Map<String, dynamic>,
            )
          : null,
      interests: (json['interests'] as List<dynamic>?)?.cast<String>(),
      activityHours: json['activityHours'] != null
          ? PlanningActivityWindowDto.fromJson(
              json['activityHours'] as Map<String, dynamic>,
            )
          : null,
      travelStyle: json['travelStyle'] as String?,
      budgetLevel: json['budgetLevel'] as String?,
      expiresAt: json['expiresAt'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      guestToken: json['guestToken'] as String,
    );
  }
}
