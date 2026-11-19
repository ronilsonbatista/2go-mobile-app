/// Layout stub for a previously saved card (2ª compra path).
class CheckoutSavedCard {
  final String lastFour;
  final String brand;

  const CheckoutSavedCard({
    required this.lastFour,
    this.brand = 'mastercard',
  });

  String get maskedLabel => 'Cartão •••• $lastFour';

  /// Design-frame stub (`Cartão **** 4405`).
  static const demoMastercard4405 = CheckoutSavedCard(lastFour: '4405');
}
