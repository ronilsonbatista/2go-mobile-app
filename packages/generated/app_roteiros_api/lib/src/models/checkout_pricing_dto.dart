class CheckoutPricingDto {
  final double originalAmount;
  final double discountAmount;
  final double finalAmount;
  final String currency;

  /// List price before coupon (alias of [originalAmount] from Core).
  final double amount;

  /// Trip length Core used for the duration tier.
  final int days;

  /// `UP_TO_7` | `FROM_8_TO_12` | `FROM_13`
  final String tier;

  const CheckoutPricingDto({
    required this.originalAmount,
    required this.discountAmount,
    required this.finalAmount,
    required this.currency,
    required this.amount,
    required this.days,
    required this.tier,
  });

  factory CheckoutPricingDto.fromJson(Map<String, dynamic> json) {
    final original =
        (json['originalAmount'] as num?)?.toDouble() ??
        (json['amount'] as num?)?.toDouble() ??
        0.0;
    return CheckoutPricingDto(
      originalAmount: original,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
      finalAmount: (json['finalAmount'] as num?)?.toDouble() ?? original,
      currency: json['currency'] as String? ?? 'BRL',
      amount: (json['amount'] as num?)?.toDouble() ?? original,
      days: (json['days'] as num?)?.toInt() ?? 0,
      tier: json['tier'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'originalAmount': originalAmount,
    'discountAmount': discountAmount,
    'finalAmount': finalAmount,
    'currency': currency,
    'amount': amount,
    'days': days,
    'tier': tier,
  };
}
