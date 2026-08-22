class CheckoutCouponDto {
  final String code;
  final bool applied;
  final String discountType;
  final double discountValue;
  final String? description;

  const CheckoutCouponDto({
    required this.code,
    required this.applied,
    required this.discountType,
    required this.discountValue,
    this.description,
  });

  factory CheckoutCouponDto.fromJson(Map<String, dynamic> json) {
    return CheckoutCouponDto(
      code: json['code'] as String? ?? '',
      applied: json['applied'] as bool? ?? false,
      discountType: json['discountType'] as String? ?? 'PERCENTAGE',
      discountValue: (json['discountValue'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'applied': applied,
    'discountType': discountType,
    'discountValue': discountValue,
    'description': description,
  };
}
