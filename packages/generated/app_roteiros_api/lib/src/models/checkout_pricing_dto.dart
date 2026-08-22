class CheckoutPricingDto {
  final double originalAmount;
  final double discountAmount;
  final double finalAmount;
  final String currency;

  const CheckoutPricingDto({
    required this.originalAmount,
    required this.discountAmount,
    required this.finalAmount,
    required this.currency,
  });

  factory CheckoutPricingDto.fromJson(Map<String, dynamic> json) {
    return CheckoutPricingDto(
      originalAmount: (json['originalAmount'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
      finalAmount: (json['finalAmount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'BRL',
    );
  }

  Map<String, dynamic> toJson() => {
    'originalAmount': originalAmount,
    'discountAmount': discountAmount,
    'finalAmount': finalAmount,
    'currency': currency,
  };
}
