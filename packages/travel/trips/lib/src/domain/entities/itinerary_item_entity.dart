enum ItineraryCategory {
  touristAttraction,
  museum,
  restaurant,
  cafe,
  bar,
  beach,
  park,
  shopping,
  experience,
  transport,
  event,
  nightlife,
  freeActivity,
  paidActivity,
}

class ItineraryItemEntity {
  final String id;
  final String tripDayId;
  final String title;
  final String? description;
  final ItineraryCategory category;
  final String? location;
  final String? googleMapsLink;
  final double? latitude;
  final double? longitude;
  final String? timeLabel;
  final String? period;
  final int? duration;
  final double? cost;
  final String? currency;
  final String? externalLink;
  final String? notes;
  final int order;
  final String? providerPlaceId;
  final String? placeProvider;
  final bool isEditable;
  final bool isUserModified;

  const ItineraryItemEntity({
    required this.id,
    required this.tripDayId,
    required this.title,
    this.description,
    this.category = ItineraryCategory.touristAttraction,
    this.location,
    this.googleMapsLink,
    this.latitude,
    this.longitude,
    this.timeLabel,
    this.period,
    this.duration,
    this.cost,
    this.currency,
    this.externalLink,
    this.notes,
    required this.order,
    this.providerPlaceId,
    this.placeProvider,
    this.isEditable = true,
    this.isUserModified = false,
  });

  ItineraryItemEntity copyWith({
    String? title,
    String? description,
    ItineraryCategory? category,
    String? location,
    String? googleMapsLink,
    double? latitude,
    double? longitude,
    String? timeLabel,
    String? period,
    int? duration,
    double? cost,
    String? currency,
    String? externalLink,
    String? notes,
    int? order,
    String? providerPlaceId,
    String? placeProvider,
    bool? isEditable,
    bool? isUserModified,
  }) {
    return ItineraryItemEntity(
      id: id,
      tripDayId: tripDayId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      location: location ?? this.location,
      googleMapsLink: googleMapsLink ?? this.googleMapsLink,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timeLabel: timeLabel ?? this.timeLabel,
      period: period ?? this.period,
      duration: duration ?? this.duration,
      cost: cost ?? this.cost,
      currency: currency ?? this.currency,
      externalLink: externalLink ?? this.externalLink,
      notes: notes ?? this.notes,
      order: order ?? this.order,
      providerPlaceId: providerPlaceId ?? this.providerPlaceId,
      placeProvider: placeProvider ?? this.placeProvider,
      isEditable: isEditable ?? this.isEditable,
      isUserModified: isUserModified ?? this.isUserModified,
    );
  }
}
