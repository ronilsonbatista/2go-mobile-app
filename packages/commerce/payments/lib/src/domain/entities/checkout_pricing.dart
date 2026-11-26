class CheckoutPricing {
  final double originalAmount;
  final double discountAmount;

  /// Amount charged after coupon — always from Core.
  final double finalAmount;
  final String currency;

  /// List price before coupon (`pricing.amount`).
  final double amount;

  /// Trip days Core used for the tier.
  final int days;

  /// `UP_TO_7` | `FROM_8_TO_12` | `FROM_13`
  final String tier;

  const CheckoutPricing({
    required this.originalAmount,
    required this.discountAmount,
    required this.finalAmount,
    required this.currency,
    this.amount = 0,
    this.days = 0,
    this.tier = '',
  });
}
