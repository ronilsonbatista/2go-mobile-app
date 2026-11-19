import 'entities/itinerary_item_entity.dart';
import 'paid_trip_controls.dart';

/// Full-screen / modal mode for Detalhes.
enum PlaceDetailsMode {
  /// Pick from search / alternatives → primary CTA selects.
  pick,

  /// Already on the itinerary → duration + substitute / delete.
  edit,
}

/// Visual kind drives cuisine row, ticket vs site link, CTA copy.
enum PlaceDetailsKind { restaurant, attraction, mealSlot, other }

/// Merged itinerary item + Core `verifiedDetails` for Detalhes UI.
///
/// Ownership (see docs/detalhes-openai-fields-2026-11-19.md):
/// Maps = facts; item.description = editorial; duration from item.
class PlaceDetailsViewData {
  final String? itemId;
  final String displayName;
  final String? description;
  final double? rating;
  final String? priceLevelDisplay;
  final String? cuisineTags;
  final String? openingHoursText;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? websiteUri;
  final String? ticketUri;
  final String? mapsUri;
  final String? ticketStatus;
  final List<String> photoUrls;
  final List<PlaceReview> reviews;
  final String? timeLabel;
  final String? period;
  final int? durationMinutes;
  final int? recommendedDurationMinutes;
  final ItineraryCategory category;
  final PlaceDetailsKind kind;
  final PlaceDetailsMode mode;
  final String? imageUrl;

  const PlaceDetailsViewData({
    this.itemId,
    required this.displayName,
    this.description,
    this.rating,
    this.priceLevelDisplay,
    this.cuisineTags,
    this.openingHoursText,
    this.address,
    this.latitude,
    this.longitude,
    this.websiteUri,
    this.ticketUri,
    this.mapsUri,
    this.ticketStatus,
    this.photoUrls = const [],
    this.reviews = const [],
    this.timeLabel,
    this.period,
    this.durationMinutes,
    this.recommendedDurationMinutes,
    this.category = ItineraryCategory.touristAttraction,
    this.kind = PlaceDetailsKind.other,
    this.mode = PlaceDetailsMode.edit,
    this.imageUrl,
  });

  bool get isRestaurantLike =>
      kind == PlaceDetailsKind.restaurant ||
      category == ItineraryCategory.restaurant ||
      category == ItineraryCategory.cafe ||
      category == ItineraryCategory.bar;

  bool get isMealSlot => kind == PlaceDetailsKind.mealSlot;

  bool get requiresTicket {
    final status = ticketStatus?.trim().toUpperCase();
    return status == 'TICKET_REQUIRED';
  }

  /// "Site oficial" for food; "Compra ingresso" when ticket required.
  String? get externalLinkLabel {
    if (requiresTicket && (ticketUri != null || websiteUri != null)) {
      return 'Compra ingresso';
    }
    if (isRestaurantLike && websiteUri != null) return 'Site oficial';
    if (ticketUri != null || websiteUri != null) {
      return requiresTicket ? 'Compra ingresso' : 'Site oficial';
    }
    return null;
  }

  String? get externalLinkUri => ticketUri ?? websiteUri;

  String get selectCtaLabel {
    if (isRestaurantLike) return 'Selecionar restaurante';
    return 'Selecionar atividade';
  }

  String get substituteCtaLabel {
    if (isRestaurantLike) return 'Substituir restaurante';
    return 'Substituir atração';
  }

  static PlaceDetailsViewData merge({
    ItineraryItemEntity? item,
    VerifiedPlaceDetails? verified,
    PlaceDetailsMode mode = PlaceDetailsMode.edit,
    String? fallbackImageUrl,
    String? cuisineOverride,
  }) {
    final category = item?.category ?? ItineraryCategory.touristAttraction;
    final kind = _resolveKind(item: item, verified: verified, category: category);

    final photos = <String>[];
    for (final photo in verified?.photos ?? const <PlacePhoto>[]) {
      final uri = photo.photoUri?.trim();
      if (uri != null && uri.isNotEmpty) photos.add(uri);
    }
    if (photos.isEmpty) {
      final fallback = fallbackImageUrl?.trim();
      if (fallback != null && fallback.isNotEmpty) photos.add(fallback);
    }

    final priceDisplay =
        verified?.priceLevelDisplay ??
        formatPriceLevelDisplay(verified?.priceLevel);

    final cuisine =
        cuisineOverride ??
        verified?.cuisineType ??
        _cuisineFromTypes(verified?.types) ??
        verified?.primaryTypeDisplayName;

    final ticketStatus = item?.ticketStatus;
    final external = _nonEmpty(item?.externalLink);
    final website = _nonEmpty(verified?.websiteUri) ?? external;
    final ticketUri = ticketStatus?.toUpperCase() == 'TICKET_REQUIRED'
        ? external ?? website
        : null;

    return PlaceDetailsViewData(
      itemId: item?.id,
      displayName: _nonEmpty(verified?.name) ??
          _nonEmpty(item?.title) ??
          'Lugar',
      description: _nonEmpty(item?.description) ??
          _nonEmpty(verified?.editorialSummary),
      rating: verified?.rating,
      priceLevelDisplay: priceDisplay,
      cuisineTags: cuisine,
      openingHoursText: verified?.openingHoursText,
      address: _nonEmpty(verified?.formattedAddress) ??
          _nonEmpty(item?.location),
      latitude: verified?.latitude ?? item?.latitude,
      longitude: verified?.longitude ?? item?.longitude,
      websiteUri: website,
      ticketUri: ticketUri,
      mapsUri: _nonEmpty(verified?.googleMapsUri) ??
          _nonEmpty(item?.googleMapsLink),
      ticketStatus: ticketStatus,
      photoUrls: photos,
      reviews: verified?.reviews ?? const [],
      timeLabel: item?.timeLabel,
      period: item?.period,
      durationMinutes: item?.duration,
      recommendedDurationMinutes: item?.duration,
      category: category,
      kind: kind,
      mode: mode,
      imageUrl: photos.isNotEmpty ? photos.first : fallbackImageUrl,
    );
  }

  PlaceDetailsViewData copyWithDuration(int minutes) {
    return PlaceDetailsViewData(
      itemId: itemId,
      displayName: displayName,
      description: description,
      rating: rating,
      priceLevelDisplay: priceLevelDisplay,
      cuisineTags: cuisineTags,
      openingHoursText: openingHoursText,
      address: address,
      latitude: latitude,
      longitude: longitude,
      websiteUri: websiteUri,
      ticketUri: ticketUri,
      mapsUri: mapsUri,
      ticketStatus: ticketStatus,
      photoUrls: photoUrls,
      reviews: reviews,
      timeLabel: timeLabel,
      period: period,
      durationMinutes: minutes,
      recommendedDurationMinutes: recommendedDurationMinutes,
      category: category,
      kind: kind,
      mode: mode,
      imageUrl: imageUrl,
    );
  }
}

PlaceDetailsKind _resolveKind({
  ItineraryItemEntity? item,
  VerifiedPlaceDetails? verified,
  required ItineraryCategory category,
}) {
  if (item != null && _isMealSlot(item)) return PlaceDetailsKind.mealSlot;

  final types = verified?.types ?? const [];
  final primary = (verified?.primaryType ?? '').toLowerCase();
  final foodType = types.any((t) {
    final lower = t.toLowerCase();
    return lower.contains('restaurant') ||
        lower.contains('cafe') ||
        lower.contains('bar') ||
        lower.contains('food');
  });

  if (category == ItineraryCategory.restaurant ||
      category == ItineraryCategory.cafe ||
      category == ItineraryCategory.bar ||
      primary.contains('restaurant') ||
      primary.contains('cafe') ||
      primary.contains('bar') ||
      foodType) {
    return PlaceDetailsKind.restaurant;
  }

  if (category == ItineraryCategory.touristAttraction ||
      category == ItineraryCategory.museum ||
      category == ItineraryCategory.park ||
      category == ItineraryCategory.paidActivity ||
      category == ItineraryCategory.freeActivity ||
      primary.contains('tourist') ||
      primary.contains('museum')) {
    return PlaceDetailsKind.attraction;
  }

  return PlaceDetailsKind.other;
}

/// Meal period placeholder without a concrete place (Modal / Modal-1).
bool _isMealSlot(ItineraryItemEntity item) {
  final hasPlace = (item.providerPlaceId?.trim().isNotEmpty ?? false);
  if (hasPlace) return false;
  final title = item.title.trim().toLowerCase();
  const slots = {
    'café da manhã',
    'cafe da manha',
    'almoço',
    'almoco',
    'jantar',
    'lanche',
    'pausa',
  };
  if (slots.contains(title)) return true;
  final period = item.period?.trim().toLowerCase() ?? '';
  if ((period == 'almoço' ||
          period == 'almoco' ||
          period == 'jantar' ||
          period == 'manhã' ||
          period == 'manha') &&
      (item.description == null || item.description!.trim().isEmpty) &&
      item.latitude == null) {
    return categoryIsFood(item.category);
  }
  return false;
}

bool categoryIsFood(ItineraryCategory category) {
  return category == ItineraryCategory.restaurant ||
      category == ItineraryCategory.cafe ||
      category == ItineraryCategory.bar;
}

/// Format minutes as `H:MM` for the duration stepper.
String formatDurationHm(int? minutes) {
  final safe = (minutes ?? 0).clamp(0, 24 * 60);
  final h = safe ~/ 60;
  final m = safe % 60;
  return '$h:${m.toString().padLeft(2, '0')}';
}

int? parseDurationHm(String raw) {
  final text = raw.trim();
  final match = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(text);
  if (match == null) return null;
  final h = int.tryParse(match.group(1)!);
  final m = int.tryParse(match.group(2)!);
  if (h == null || m == null || m >= 60) return null;
  return h * 60 + m;
}

/// Map Core / Google priceLevel → `$`…`$$$$` when `priceLevelDisplay` absent.
String? formatPriceLevelDisplay(String? raw) {
  if (raw == null) return null;
  final value = raw.trim();
  if (value.isEmpty) return null;
  if (RegExp(r'^\$+$').hasMatch(value)) return value;

  const named = {
    'PRICE_LEVEL_FREE': null,
    'PRICE_LEVEL_INEXPENSIVE': '\$',
    'PRICE_LEVEL_MODERATE': '\$\$',
    'PRICE_LEVEL_EXPENSIVE': '\$\$\$',
    'PRICE_LEVEL_VERY_EXPENSIVE': '\$\$\$\$',
  };
  if (named.containsKey(value)) return named[value];

  final asInt = int.tryParse(value);
  if (asInt != null) {
    if (asInt <= 0) return null;
    return '\$' * asInt.clamp(1, 4);
  }
  return null;
}

String? _cuisineFromTypes(List<String>? types) {
  if (types == null || types.isEmpty) return null;
  final labels = <String>[];
  for (final type in types) {
    final lower = type.toLowerCase();
    if (lower == 'restaurant' ||
        lower == 'food' ||
        lower == 'point_of_interest' ||
        lower == 'establishment') {
      continue;
    }
    if (lower.contains('italian')) {
      labels.add('Italiana');
    } else if (lower.contains('mediterranean')) {
      labels.add('Mediterrânea');
    } else if (lower.contains('pizza')) {
      labels.add('Pizza');
    } else if (lower.contains('seafood')) {
      labels.add('Frutos do mar');
    } else if (lower.contains('cafe') || lower.contains('coffee')) {
      labels.add('Café');
    } else if (lower.contains('bar')) {
      labels.add('Bar');
    }
  }
  if (labels.isEmpty) return null;
  return labels.toSet().join(', ');
}

String? _nonEmpty(String? value) {
  final text = value?.trim();
  if (text == null || text.isEmpty) return null;
  return text;
}
