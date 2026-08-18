class PlanningActivityWindowDto {
  final String startTime;
  final String endTime;

  const PlanningActivityWindowDto({
    required this.startTime,
    required this.endTime,
  });

  Map<String, dynamic> toJson() => {'startTime': startTime, 'endTime': endTime};

  factory PlanningActivityWindowDto.fromJson(Map<String, dynamic> json) {
    return PlanningActivityWindowDto(
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
    );
  }
}
