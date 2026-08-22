import 'checkout_payment_result.dart';

class PurchaseStatusResult {
  final String purchaseId;
  final String status;
  final String? paidAt;
  final bool premiumUnlocked;
  final PixDetails? pixDetails;

  const PurchaseStatusResult({
    required this.purchaseId,
    required this.status,
    this.paidAt,
    this.premiumUnlocked = false,
    this.pixDetails,
  });
}
