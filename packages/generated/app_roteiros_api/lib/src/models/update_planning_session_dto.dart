import 'planning_activity_window_dto.dart';
import 'planning_destination_dto.dart';
import 'planning_travelers_dto.dart';

class UpdatePlanningSessionDto {
  final int? currentStep;
  final List<PlanningDestinationDto>? destinations;
  final PlanningTravelersDto? travelers;
  final List<String>? interests;
  final PlanningActivityWindowDto? activityWindow;
  final String? travelStyle;
  final String? budgetLevel;

  const UpdatePlanningSessionDto({
    this.currentStep,
    this.destinations,
    this.travelers,
    this.interests,
    this.activityWindow,
    this.travelStyle,
    this.budgetLevel,
  });

  Map<String, dynamic> toJson() => {
    if (currentStep != null) 'currentStep': currentStep,
    if (destinations != null)
      'destinations': destinations!.map((e) => e.toJson()).toList(),
    if (travelers != null) 'travelers': travelers!.toJson(),
    if (interests != null) 'interests': interests,
    if (activityWindow != null) 'activityWindow': activityWindow!.toJson(),
    if (travelStyle != null) 'travelStyle': travelStyle,
    if (budgetLevel != null) 'budgetLevel': budgetLevel,
  };

  factory UpdatePlanningSessionDto.fromJson(Map<String, dynamic> json) {
    return UpdatePlanningSessionDto(
      currentStep: json['currentStep'] as int?,
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
      activityWindow: json['activityWindow'] != null
          ? PlanningActivityWindowDto.fromJson(
              json['activityWindow'] as Map<String, dynamic>,
            )
          : null,
      travelStyle: json['travelStyle'] as String?,
      budgetLevel: json['budgetLevel'] as String?,
    );
  }
}
