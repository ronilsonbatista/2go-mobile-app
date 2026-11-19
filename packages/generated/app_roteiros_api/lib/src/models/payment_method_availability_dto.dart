class PaymentMethodAvailabilityDto {
  final String method;
  final bool available;
  final String status;
  final String? reason;

  const PaymentMethodAvailabilityDto({
    required this.method,
    required this.available,
    required this.status,
    this.reason,
  });

  factory PaymentMethodAvailabilityDto.fromJson(Map<String, dynamic> json) {
    return PaymentMethodAvailabilityDto(
      method: json['method'] as String? ?? '',
      available: json['available'] as bool? ?? false,
      status: json['status'] as String? ?? 'COMING_SOON',
      reason: json['reason'] as String?,
    );
  }
}
