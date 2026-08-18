class PlanningDestinationDto {
  final String? providerPlaceId;
  final String name;
  final String? city;
  final String? country;
  final String? coverImage;
  final String arrivalDate;
  final String arrivalTime;
  final String departureDate;
  final String departureTime;
  final int? order;

  const PlanningDestinationDto({
    this.providerPlaceId,
    required this.name,
    this.city,
    this.country,
    this.coverImage,
    required this.arrivalDate,
    required this.arrivalTime,
    required this.departureDate,
    required this.departureTime,
    this.order,
  });

  Map<String, dynamic> toJson() => {
    if (providerPlaceId != null) 'providerPlaceId': providerPlaceId,
    'name': name,
    if (city != null) 'city': city,
    if (country != null) 'country': country,
    if (coverImage != null) 'coverImage': coverImage,
    'arrivalDate': arrivalDate,
    'arrivalTime': arrivalTime,
    'departureDate': departureDate,
    'departureTime': departureTime,
    if (order != null) 'order': order,
  };

  factory PlanningDestinationDto.fromJson(Map<String, dynamic> json) {
    return PlanningDestinationDto(
      providerPlaceId: json['providerPlaceId'] as String?,
      name: json['name'] as String,
      city: json['city'] as String?,
      country: json['country'] as String?,
      coverImage: json['coverImage'] as String?,
      arrivalDate: json['arrivalDate'] as String,
      arrivalTime: json['arrivalTime'] as String,
      departureDate: json['departureDate'] as String,
      departureTime: json['departureTime'] as String,
      order: json['order'] as int?,
    );
  }
}
