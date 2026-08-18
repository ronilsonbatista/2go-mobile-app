class PlanningTravelers {
  final int adults;
  final int children;
  final int elders;

  const PlanningTravelers({
    required this.adults,
    required this.children,
    required this.elders,
  });

  int get total => adults + children + elders;
}
