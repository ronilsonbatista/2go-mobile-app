/// Candidate lodging chosen from Places or manual address entry.
class AccommodationCandidate {
  final String name;
  final String? address;
  final String? neighborhood;
  final String? zipCode;
  final double? latitude;
  final double? longitude;
  final String? providerPlaceId;

  const AccommodationCandidate({
    required this.name,
    this.address,
    this.neighborhood,
    this.zipCode,
    this.latitude,
    this.longitude,
    this.providerPlaceId,
  });

  bool get hasCoordinates => latitude != null && longitude != null;
}
