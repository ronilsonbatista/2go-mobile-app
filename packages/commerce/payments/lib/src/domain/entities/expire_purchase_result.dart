/// Result of `POST /purchases/:id/expire`.
class ExpirePurchaseResult {
  final String purchaseId;
  final String status;
  final String? expiredAt;
  final String? message;

  const ExpirePurchaseResult({
    required this.purchaseId,
    required this.status,
    this.expiredAt,
    this.message,
  });
}
