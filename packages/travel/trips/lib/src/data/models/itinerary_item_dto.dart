import '../../domain/entities/itinerary_item_entity.dart';

class ItineraryItemDto {
  final String id;
  final String tripDayId;
  final String title;
  final String? description;
  final String category;
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

  const ItineraryItemDto({
    required this.id,
    required this.tripDayId,
    required this.title,
    this.description,
    required this.category,
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

  factory ItineraryItemDto.fromJson(Map<String, dynamic> json) {
    return ItineraryItemDto(
      id: json['id'] as String? ?? '',
      tripDayId: json['tripDayId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      category: json['category'] as String? ?? 'TOURIST_ATTRACTION',
      location: json['location'] as String?,
      googleMapsLink: json['googleMapsLink'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      timeLabel: json['timeLabel'] as String?,
      period: json['period'] as String?,
      duration: json['duration'] as int?,
      cost: (json['cost'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
      externalLink: json['externalLink'] as String?,
      notes: json['notes'] as String?,
      order: json['order'] as int? ?? 0,
      providerPlaceId: json['providerPlaceId'] as String?,
      placeProvider: json['placeProvider'] as String?,
      isEditable: json['isEditable'] as bool? ?? true,
      isUserModified: json['isUserModified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tripDayId': tripDayId,
      'title': title,
      'description': description,
      'category': category,
      'location': location,
      'googleMapsLink': googleMapsLink,
      'latitude': latitude,
      'longitude': longitude,
      'timeLabel': timeLabel,
      'period': period,
      'duration': duration,
      'cost': cost,
      'currency': currency,
      'externalLink': externalLink,
      'notes': notes,
      'order': order,
      'providerPlaceId': providerPlaceId,
      'placeProvider': placeProvider,
      'isEditable': isEditable,
      'isUserModified': isUserModified,
    };
  }

  ItineraryItemEntity toEntity() {
    return ItineraryItemEntity(
      id: id,
      tripDayId: tripDayId,
      title: title,
      description: description,
      category: _mapCategory(category),
      location: location,
      googleMapsLink: googleMapsLink,
      latitude: latitude,
      longitude: longitude,
      timeLabel: timeLabel,
      period: period,
      duration: duration,
      cost: cost,
      currency: currency,
      externalLink: externalLink,
      notes: notes,
      order: order,
      providerPlaceId: providerPlaceId,
      placeProvider: placeProvider,
      isEditable: isEditable,
      isUserModified: isUserModified,
    );
  }

  static ItineraryCategory _mapCategory(String cat) {
    switch (cat.toUpperCase()) {
      case 'MUSEUM':
        return ItineraryCategory.museum;
      case 'RESTAURANT':
        return ItineraryCategory.restaurant;
      case 'CAFE':
        return ItineraryCategory.cafe;
      case 'BAR':
        return ItineraryCategory.bar;
      case 'BEACH':
        return ItineraryCategory.beach;
      case 'PARK':
        return ItineraryCategory.park;
      case 'SHOPPING':
        return ItineraryCategory.shopping;
      case 'EXPERIENCE':
        return ItineraryCategory.experience;
      case 'TRANSPORT':
        return ItineraryCategory.transport;
      case 'EVENT':
        return ItineraryCategory.event;
      case 'NIGHTLIFE':
        return ItineraryCategory.nightlife;
      case 'FREE_ACTIVITY':
        return ItineraryCategory.freeActivity;
      case 'PAID_ACTIVITY':
        return ItineraryCategory.paidActivity;
      case 'TOURIST_ATTRACTION':
      default:
        return ItineraryCategory.touristAttraction;
    }
  }
}
