/// Campos que os endpoints da Fase 3 devolvem.
///
/// Cada fábrica só lê chaves presentes. Corpo de escrita omite nulos.
class SwapQuota {
  final int? allowedSwapsCount;
  final int? usedSwapsCount;
  final int? remainingSwaps;

  const SwapQuota({
    this.allowedSwapsCount,
    this.usedSwapsCount,
    this.remainingSwaps,
  });

  factory SwapQuota.fromJson(Map<String, dynamic> json) {
    return SwapQuota(
      allowedSwapsCount: _readInt(json['allowedSwapsCount']),
      usedSwapsCount: _readInt(json['usedSwapsCount']),
      remainingSwaps: _readInt(json['remainingSwaps']),
    );
  }

  /// "Trocas: X de Y" só quando os dois contadores vieram.
  String? get label {
    if (usedSwapsCount == null || allowedSwapsCount == null) return null;
    return 'Trocas: $usedSwapsCount de $allowedSwapsCount';
  }

  bool get canSubstitute {
    if (remainingSwaps != null) return remainingSwaps! > 0;
    if (usedSwapsCount != null && allowedSwapsCount != null) {
      return usedSwapsCount! < allowedSwapsCount!;
    }
    return false;
  }

  bool get exhausted {
    if (remainingSwaps != null) return remainingSwaps! <= 0;
    if (usedSwapsCount != null && allowedSwapsCount != null) {
      return usedSwapsCount! >= allowedSwapsCount!;
    }
    return false;
  }
}

class ItemAlternative {
  final String? title;
  final String? description;
  final String? category;
  final String? location;
  final String? providerPlaceId;
  final double? latitude;
  final double? longitude;
  final double? cost;
  final String? currency;
  final int? duration;
  final String? ticketStatus;
  final String? source;
  final double? rating;
  final int? userRatingsTotal;
  final String? googleMapsUri;

  const ItemAlternative({
    this.title,
    this.description,
    this.category,
    this.location,
    this.providerPlaceId,
    this.latitude,
    this.longitude,
    this.cost,
    this.currency,
    this.duration,
    this.ticketStatus,
    this.source,
    this.rating,
    this.userRatingsTotal,
    this.googleMapsUri,
  });

  factory ItemAlternative.fromJson(Map<String, dynamic> json) {
    return ItemAlternative(
      title: _readText(json['title']),
      description: _readText(json['description']),
      category: _readText(json['category']),
      location: _readText(json['location']),
      providerPlaceId: _readText(json['providerPlaceId']),
      latitude: _readDouble(json['latitude']),
      longitude: _readDouble(json['longitude']),
      cost: _readDouble(json['cost']),
      currency: _readText(json['currency']),
      duration: _readInt(json['duration']),
      ticketStatus: _readText(json['ticketStatus']),
      source: _readText(json['source']),
      rating: _readDouble(json['rating']),
      userRatingsTotal: _readInt(json['userRatingsTotal']),
      googleMapsUri: _readText(json['googleMapsUri']),
    );
  }

  /// Corpo de `POST /itinerary-items/:id/substitute`. Nulo sem título.
  Map<String, dynamic>? toSubstituteBody() {
    final safeTitle = title?.trim();
    if (safeTitle == null || safeTitle.isEmpty) return null;
    final body = <String, dynamic>{'title': safeTitle};
    _put(body, 'description', description);
    _put(body, 'category', category);
    _put(body, 'location', location);
    _put(body, 'providerPlaceId', providerPlaceId);
    _put(body, 'latitude', latitude);
    _put(body, 'longitude', longitude);
    _put(body, 'cost', cost);
    _put(body, 'currency', currency);
    _put(body, 'duration', duration);
    _put(body, 'ticketStatus', ticketStatus);
    return body;
  }
}

class AlternativesResult {
  final List<ItemAlternative> items;
  final SwapQuota quota;

  const AlternativesResult({required this.items, required this.quota});

  factory AlternativesResult.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = rawItems is List
        ? rawItems
              .whereType<Map<dynamic, dynamic>>()
              .map(
                (item) =>
                    ItemAlternative.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList()
        : const <ItemAlternative>[];
    final rawQuota = json['quota'];
    final quota = rawQuota is Map
        ? SwapQuota.fromJson(Map<String, dynamic>.from(rawQuota))
        : const SwapQuota();
    return AlternativesResult(items: items, quota: quota);
  }
}

class MealRecommendation {
  final String? name;
  final String? cuisineType;
  final String? priceRange;
  final String? priceLevel;
  final String? recommendedDish;
  final String? address;
  final String? providerPlaceId;
  final double? latitude;
  final double? longitude;
  final double? rating;
  final int? userRatingsTotal;
  final String? googleMapsUri;
  final String? source;
  final String? description;

  const MealRecommendation({
    this.name,
    this.cuisineType,
    this.priceRange,
    this.priceLevel,
    this.recommendedDish,
    this.address,
    this.providerPlaceId,
    this.latitude,
    this.longitude,
    this.rating,
    this.userRatingsTotal,
    this.googleMapsUri,
    this.source,
    this.description,
  });

  factory MealRecommendation.fromJson(Map<String, dynamic> json) {
    return MealRecommendation(
      name: _readText(json['name']),
      cuisineType: _readText(json['cuisineType']),
      priceRange: _readText(json['priceRange']),
      priceLevel: _readRaw(json['priceLevel']),
      recommendedDish: _readText(json['recommendedDish']),
      address: _readText(json['address']),
      providerPlaceId: _readText(json['providerPlaceId']),
      latitude: _readDouble(json['latitude']),
      longitude: _readDouble(json['longitude']),
      rating: _readDouble(json['rating']),
      userRatingsTotal: _readInt(json['userRatingsTotal']),
      googleMapsUri: _readText(json['googleMapsUri']),
      source: _readText(json['source']),
      description: _readText(json['description']),
    );
  }

  /// Corpo de `PATCH /itinerary-items/:id/pin-meal`.
  ///
  /// Não deriva custo de `priceLevel` nem de `priceRange`.
  Map<String, dynamic>? toPinBody() {
    final safeTitle = name?.trim();
    if (safeTitle == null || safeTitle.isEmpty) return null;
    final body = <String, dynamic>{'title': safeTitle};
    _put(body, 'description', description);
    _put(body, 'location', address);
    _put(body, 'providerPlaceId', providerPlaceId);
    _put(body, 'latitude', latitude);
    _put(body, 'longitude', longitude);
    _put(body, 'notes', recommendedDish);
    _put(body, 'googleMapsLink', googleMapsUri);
    return body;
  }
}

class MealRecommendationsResult {
  final String? destination;
  final String? period;
  final List<MealRecommendation> recommendations;

  const MealRecommendationsResult({
    this.destination,
    this.period,
    this.recommendations = const [],
  });

  factory MealRecommendationsResult.fromJson(Map<String, dynamic> json) {
    final raw = json['recommendations'];
    final recommendations = raw is List
        ? raw
              .whereType<Map<dynamic, dynamic>>()
              .map(
                (item) => MealRecommendation.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
        : const <MealRecommendation>[];
    return MealRecommendationsResult(
      destination: _readText(json['destination']),
      period: _readText(json['period']),
      recommendations: recommendations,
    );
  }
}

class VerifiedPlaceDetails {
  final String? name;
  final String? formattedAddress;
  final double? rating;
  final int? userRatingsTotal;
  final String? googleMapsUri;
  final String? websiteUri;
  final String? internationalPhoneNumber;
  final String? priceLevel;
  final List<String>? types;

  const VerifiedPlaceDetails({
    this.name,
    this.formattedAddress,
    this.rating,
    this.userRatingsTotal,
    this.googleMapsUri,
    this.websiteUri,
    this.internationalPhoneNumber,
    this.priceLevel,
    this.types,
  });

  factory VerifiedPlaceDetails.fromJson(Map<String, dynamic> json) {
    final rawTypes = json['types'];
    final types = rawTypes is List
        ? rawTypes
              .whereType<String>()
              .map((type) => type.trim())
              .where((type) => type.isNotEmpty)
              .toList()
        : null;
    return VerifiedPlaceDetails(
      name: _readText(json['name']),
      formattedAddress: _readText(json['formattedAddress']),
      rating: _readDouble(json['rating']),
      userRatingsTotal: _readInt(json['userRatingsTotal']),
      googleMapsUri: _readText(json['googleMapsUri']),
      websiteUri: _readText(json['websiteUri']),
      internationalPhoneNumber: _readText(json['internationalPhoneNumber']),
      priceLevel: _readRaw(json['priceLevel']),
      types: types == null || types.isEmpty ? null : types,
    );
  }

  bool get hasAny =>
      name != null ||
      formattedAddress != null ||
      rating != null ||
      userRatingsTotal != null ||
      googleMapsUri != null ||
      websiteUri != null ||
      internationalPhoneNumber != null ||
      priceLevel != null ||
      (types != null && types!.isNotEmpty);
}

class AccommodationDraft {
  final String name;
  final String? address;
  final String? neighborhood;
  final String? zipCode;
  final double? latitude;
  final double? longitude;
  final String? providerPlaceId;
  final String? checkInDateTime;
  final String? checkOutDateTime;
  final String? checkInDate;
  final String? checkInTime;
  final String? checkOutDate;
  final String? checkOutTime;

  const AccommodationDraft({
    required this.name,
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

  factory AccommodationDraft.fromJson(Map<String, dynamic> json) {
    return AccommodationDraft(
      name: _readText(json['name']) ?? '',
      address: _readText(json['address']),
      neighborhood: _readText(json['neighborhood']),
      zipCode: _readText(json['zipCode']),
      latitude: _readDouble(json['latitude']),
      longitude: _readDouble(json['longitude']),
      providerPlaceId: _readText(json['providerPlaceId']),
      checkInDateTime: _readText(json['checkInDateTime']),
      checkOutDateTime: _readText(json['checkOutDateTime']),
      checkInDate: _readText(json['checkInDate']),
      checkInTime: _readText(json['checkInTime']),
      checkOutDate: _readText(json['checkOutDate']),
      checkOutTime: _readText(json['checkOutTime']),
    );
  }

  /// Reenvia os campos carregados. O upsert do core zera latitude,
  /// longitude e endereço quando o corpo os omite.
  Map<String, dynamic> toJson() {
    final body = <String, dynamic>{'name': name.trim()};
    _put(body, 'address', address);
    _put(body, 'neighborhood', neighborhood);
    _put(body, 'zipCode', zipCode);
    _put(body, 'latitude', latitude);
    _put(body, 'longitude', longitude);
    _put(body, 'providerPlaceId', providerPlaceId);
    _put(body, 'checkInDateTime', checkInDateTime);
    _put(body, 'checkOutDateTime', checkOutDateTime);
    _put(body, 'checkInDate', checkInDate);
    _put(body, 'checkInTime', checkInTime);
    _put(body, 'checkOutDate', checkOutDate);
    _put(body, 'checkOutTime', checkOutTime);
    return body;
  }
}

void _put(Map<String, dynamic> body, String key, Object? value) {
  if (value == null) return;
  if (value is String && value.trim().isEmpty) return;
  body[key] = value is String ? value.trim() : value;
}

String? _readText(dynamic raw) {
  if (raw is! String) return null;
  final value = raw.trim();
  return value.isEmpty ? null : value;
}

String? _readRaw(dynamic raw) {
  if (raw == null) return null;
  if (raw is String) return _readText(raw);
  if (raw is num || raw is bool) return raw.toString();
  return null;
}

double? _readDouble(dynamic raw) {
  if (raw is num) return raw.toDouble();
  return null;
}

int? _readInt(dynamic raw) {
  if (raw is int) return raw;
  if (raw is num) return raw.toInt();
  return null;
}
