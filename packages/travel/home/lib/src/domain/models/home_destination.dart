import 'package:equatable/equatable.dart';

/// A destination shown in the Home hero carousel and "Destinos em alta" strip.
class HomeDestination extends Equatable {
  const HomeDestination({
    required this.id,
    required this.name,
    required this.country,
    required this.heroAssetPath,
    required this.cardAssetPath,
    this.imageUrl,
    this.sortOrder = 0,
  });

  final String id;
  final String name;
  final String country;

  /// Local asset used while Core CDN is unavailable.
  final String heroAssetPath;

  /// Portrait card asset (may equal [heroAssetPath]).
  final String cardAssetPath;

  /// Future remote URL from Core (preferred when non-null).
  final String? imageUrl;

  final int sortOrder;

  String get caption => '$name - $country';

  @override
  List<Object?> get props => [
    id,
    name,
    country,
    heroAssetPath,
    cardAssetPath,
    imageUrl,
    sortOrder,
  ];
}
