enum PurchaseStatus { pending, paid, cancelled, expired, refunded }

class PurchaseEntity {
  final String id;
  final String userId;
  final String productId;
  final String? tripId;
  final PurchaseStatus status;
  final double amount;
  final String currency;
  final String? mockPaymentId;
  final DateTime? paidAt;
  final DateTime? cancelledAt;

  const PurchaseEntity({
    required this.id,
    required this.userId,
    required this.productId,
    this.tripId,
    required this.status,
    required this.amount,
    this.currency = 'BRL',
    this.mockPaymentId,
    this.paidAt,
    this.cancelledAt,
  });

  bool get isPaid => status == PurchaseStatus.paid;
}
