class PlanningTravelers {
  final int adults;
  final int children;
  final int elders;

  const PlanningTravelers({
    this.adults = 1,
    this.children = 0,
    this.elders = 0,
  });

  int get total => adults + children + elders;

  PlanningTravelers copyWith({int? adults, int? children, int? elders}) {
    return PlanningTravelers(
      adults: adults ?? this.adults,
      children: children ?? this.children,
      elders: elders ?? this.elders,
    );
  }

  Map<String, dynamic> toJson() => {
    'adults': adults,
    'children': children,
    'elders': elders,
  };

  factory PlanningTravelers.fromJson(Map<String, dynamic> json) {
    return PlanningTravelers(
      adults: json['adults'] as int? ?? 1,
      children: json['children'] as int? ?? 0,
      elders: json['elders'] as int? ?? 0,
    );
  }
}
