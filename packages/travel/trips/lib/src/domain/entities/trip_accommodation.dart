class TripAccommodation {
  final String id;
  final String? name;
  final String? address;
  final String? neighborhood;
  final String? zipCode;
  final double? latitude;
  final double? longitude;
  final String? providerPlaceId;
  final DateTime? checkInDateTime;
  final DateTime? checkOutDateTime;
  final DateTime? checkInDate;
  final String? checkInTime;
  final DateTime? checkOutDate;
  final String? checkOutTime;

  const TripAccommodation({
    required this.id,
    this.name,
    this.address,
    this.neighborhood,
    this.zipCode,
    this.latitude,
    this.longitude,
    this.providerPlaceId,
    this.checkInDateTime,
    this.checkOutDateTime,
    this.checkInDate,
    this.checkInTime,
    this.checkOutDate,
    this.checkOutTime,
  });
}
