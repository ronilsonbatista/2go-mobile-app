import 'package:equatable/equatable.dart';

/// Layout model for Roteiros expirados.
///
/// Core has no expired-itineraries endpoint yet — design stubs only.
class ExpiredItinerary extends Equatable {
  const ExpiredItinerary({
    required this.id,
    required this.destination,
    required this.daysLabel,
    this.imageUrl,
    this.imageAssetPath,
    this.discountLabel = 'até 50% OFF',
  });

  final String id;
  final String destination;
  final String daysLabel;
  final String? imageUrl;
  final String? imageAssetPath;
  final String discountLabel;

  static const designDemos = <ExpiredItinerary>[
    ExpiredItinerary(
      id: 'expired_sp',
      destination: 'São Paulo',
      daysLabel: '5 dias',
    ),
    ExpiredItinerary(
      id: 'expired_paris',
      destination: 'Paris',
      daysLabel: '7 dias',
    ),
  ];

  @override
  List<Object?> get props => [
        id,
        destination,
        daysLabel,
        imageUrl,
        imageAssetPath,
        discountLabel,
      ];
}
