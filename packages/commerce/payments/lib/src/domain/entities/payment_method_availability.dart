/// Carrinho payment method matrix from Core (`paymentMethodAvailability`).
class PaymentMethodAvailability {
  final String method;
  final bool available;
  final String status;
  final String? reason;

  const PaymentMethodAvailability({
    required this.method,
    required this.available,
    required this.status,
    this.reason,
  });

  bool get isComingSoon => status.toUpperCase() == 'COMING_SOON';
}
