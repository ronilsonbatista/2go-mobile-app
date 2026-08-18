class PlanningDestination {
  final String? providerPlaceId;
  final String name;
  final String? city;
  final String? country;
  final String? coverImage;
  final String arrivalDate;
  final String arrivalTime;
  final String departureDate;
  final String departureTime;
  final int order;

  const PlanningDestination({
    this.providerPlaceId,
    required this.name,
    this.city,
    this.country,
    this.coverImage,
    required this.arrivalDate,
    required this.arrivalTime,
    required this.departureDate,
    required this.departureTime,
    this.order = 1,
  });
}
