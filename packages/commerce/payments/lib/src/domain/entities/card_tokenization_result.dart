class CardTokenizationResult {
  final String cardToken;
  final String? paymentMethodId;
  final String? issuerId;
  final int installments;
  final String? last4;

  const CardTokenizationResult({
    required this.cardToken,
    this.paymentMethodId,
    this.issuerId,
    this.installments = 1,
    this.last4,
  });

  @override
  String toString() {
    return 'CardTokenizationResult(cardToken: [REDACTED_TOKEN], paymentMethodId: $paymentMethodId, installments: $installments, last4: $last4)';
  }
}
