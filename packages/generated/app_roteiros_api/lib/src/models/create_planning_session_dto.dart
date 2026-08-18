class CreatePlanningSessionDto {
  final int? answersVersion;
  final int? initialStep;

  const CreatePlanningSessionDto({this.answersVersion, this.initialStep});

  Map<String, dynamic> toJson() => {
    if (answersVersion != null) 'answersVersion': answersVersion,
    if (initialStep != null) 'initialStep': initialStep,
  };

  factory CreatePlanningSessionDto.fromJson(Map<String, dynamic> json) {
    return CreatePlanningSessionDto(
      answersVersion: json['answersVersion'] as int?,
      initialStep: json['initialStep'] as int?,
    );
  }
}
