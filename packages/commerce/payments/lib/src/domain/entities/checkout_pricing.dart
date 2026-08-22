class CheckoutPricing {
  final double originalAmount;
  final double discountAmount;
  final double finalAmount;
  final String currency;

  const CheckoutPricing({
    required this.originalAmount,
    required this.discountAmount,
    required this.finalAmount,
    required this.currency,
  });
}
