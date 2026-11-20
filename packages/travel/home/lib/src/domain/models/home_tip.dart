import 'package:equatable/equatable.dart';

/// Travel tip card for "Dicas para você" (`GET /home/tips` / embedded in trip).
///
/// Content comes from Core; the app never invents tip copy. Cap ≤3 per
/// destination is enforced by Core and re-checked in [HomeTipsParser].
class HomeTip extends Equatable {
  const HomeTip({
    required this.id,
    required this.title,
    required this.body,
    this.destinationKey,
    this.destinationName,
    this.sortOrder = 0,
    this.source,
    this.providerPlaceId,
  });

  final String id;
  final String title;
  final String body;
  final String? destinationKey;
  final String? destinationName;
  final int sortOrder;

  /// `PLACEHOLDER` | `ITINERARY_PIN` | `GROK`
  final String? source;
  final String? providerPlaceId;

  @override
  List<Object?> get props => [
        id,
        title,
        body,
        destinationKey,
        destinationName,
        sortOrder,
        source,
        providerPlaceId,
      ];
}
