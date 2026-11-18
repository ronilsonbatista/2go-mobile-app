class PlaceSearchResult {
  final String providerPlaceId;
  final String name;
  final String? formattedAddress;
  final double? latitude;
  final double? longitude;
  final List<String> types;

  /// Predefined locality thumb/icon from Core Places autocomplete (CDN).
  final String? iconUrl;

  const PlaceSearchResult({
    required this.providerPlaceId,
    required this.name,
    this.formattedAddress,
    this.latitude,
    this.longitude,
    this.types = const [],
    this.iconUrl,
  });

  String get city {
    if (formattedAddress != null && formattedAddress!.contains(',')) {
      final parts = formattedAddress!.split(',');
      return parts.first.trim();
    }
    return name;
  }

  String get country {
    if (formattedAddress != null && formattedAddress!.contains(',')) {
      final parts = formattedAddress!.split(',');
      return parts.last.trim();
    }
    return '';
  }
}
