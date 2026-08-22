class AppliedCoupon {
  final String code;
  final bool applied;
  final String discountType;
  final double discountValue;
  final String? description;

  const AppliedCoupon({
    required this.code,
    required this.applied,
    required this.discountType,
    required this.discountValue,
    this.description,
  });
}
