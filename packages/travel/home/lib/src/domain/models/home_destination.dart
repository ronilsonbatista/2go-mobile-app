import 'package:equatable/equatable.dart';

/// A destination shown in the Home hero carousel and "Destinos em alta" strip.
class HomeDestination extends Equatable {
  const HomeDestination({
    required this.id,
    required this.name,
    required this.country,
    this.heroAssetPath = '',
    this.cardAssetPath = '',
    this.imageUrl,
    this.cardImageUrl,
    this.providerPlaceId,
    this.sortOrder = 0,
    this.active = true,
  });

  final String id;
  final String name;
  final String country;

  /// Local asset used while Core CDN is unavailable.
  final String heroAssetPath;

  /// Portrait card asset (may equal [heroAssetPath]).
  final String cardAssetPath;

  /// Remote hero URL from Core (`GET /home/destinations`).
  final String? imageUrl;

  /// Optional remote card URL; falls back to [imageUrl] when absent.
  final String? cardImageUrl;

  /// Google Places id from Core (`providerPlaceId`). Required on remote Home
  /// items; used to seed Onde step-1 without re-search.
  final String? providerPlaceId;

  final int sortOrder;

  /// Core marks PUBLISHED+PUBLIC rows as active; inactive items are filtered out.
  final bool active;

  String get caption => '$name - $country';

  /// Prefer remote hero URL, else local asset.
  String? get resolvedHeroUrl {
    final url = imageUrl?.trim();
    if (url != null && url.isNotEmpty) return url;
    return null;
  }

  /// Prefer card URL, then hero URL, else local asset.
  String? get resolvedCardUrl {
    final card = cardImageUrl?.trim();
    if (card != null && card.isNotEmpty) return card;
    return resolvedHeroUrl;
  }

  bool get hasRemoteHero => resolvedHeroUrl != null;
  bool get hasRemoteCard => resolvedCardUrl != null;
  bool get hasLocalHero => heroAssetPath.trim().isNotEmpty;
  bool get hasLocalCard => cardAssetPath.trim().isNotEmpty;

  @override
  List<Object?> get props => [
    id,
    name,
    country,
    heroAssetPath,
    cardAssetPath,
    imageUrl,
    cardImageUrl,
    providerPlaceId,
    sortOrder,
    active,
  ];
}
