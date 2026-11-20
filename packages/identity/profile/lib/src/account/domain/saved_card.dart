import 'package:equatable/equatable.dart';

/// Layout model for Cartões salvos.
///
/// Core has no saved-cards list/delete API yet — UI uses local/demo cards
/// matching checkout stubs (do not invent Core endpoints).
class SavedCard extends Equatable {
  const SavedCard({
    required this.id,
    required this.lastFour,
    this.brand = SavedCardBrand.mastercard,
  });

  final String id;
  final String lastFour;
  final SavedCardBrand brand;

  String get maskedLabel => 'Cartão •••• $lastFour';

  static const demoMastercard4405 = SavedCard(
    id: 'demo_mc_4405',
    lastFour: '4405',
    brand: SavedCardBrand.mastercard,
  );

  static const demoVisa6789 = SavedCard(
    id: 'demo_visa_6789',
    lastFour: '6789',
    brand: SavedCardBrand.visa,
  );

  static const List<SavedCard> designDemos = [
    demoMastercard4405,
    demoVisa6789,
  ];

  @override
  List<Object?> get props => [id, lastFour, brand];
}

enum SavedCardBrand { mastercard, visa }
