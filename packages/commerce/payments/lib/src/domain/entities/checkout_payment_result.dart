class PixDetails {
  final String? copyPaste;
  final String? qrCodeBase64;
  final String? expiresAt;

  const PixDetails({
    this.copyPaste,
    this.qrCodeBase64,
    this.expiresAt,
  });
}

class CheckoutPaymentResult {
  final String purchaseId;
  final String status;
  final String paymentMethod;
  final PixDetails? pixDetails;

  const CheckoutPaymentResult({
    required this.purchaseId,
    required this.status,
    required this.paymentMethod,
    this.pixDetails,
  });
}
