class PlanningTravelersDto {
  final int adults;
  final int children;
  final int elders;

  const PlanningTravelersDto({
    required this.adults,
    required this.children,
    required this.elders,
  });

  Map<String, dynamic> toJson() => {
    'adults': adults,
    'children': children,
    'elders': elders,
  };

  factory PlanningTravelersDto.fromJson(Map<String, dynamic> json) {
    return PlanningTravelersDto(
      adults: json['adults'] as int? ?? 0,
      children: json['children'] as int? ?? 0,
      elders: json['elders'] as int? ?? 0,
    );
  }
}
