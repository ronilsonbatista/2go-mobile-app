class PurchaseStatusResult {
  final String purchaseId;
  final String status;
  final String? paidAt;
  final bool premiumUnlocked;

  const PurchaseStatusResult({
    required this.purchaseId,
    required this.status,
    this.paidAt,
    this.premiumUnlocked = false,
  });
}
