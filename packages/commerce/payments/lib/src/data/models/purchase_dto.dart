import '../../domain/entities/purchase_entity.dart';

class PurchaseDto {
  final String id;
  final String userId;
  final String productId;
  final String? tripId;
  final String status;
  final double amount;
  final String currency;
  final String? mockPaymentId;
  final String? paidAt;
  final String? cancelledAt;

  const PurchaseDto({
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

  factory PurchaseDto.fromJson(Map<String, dynamic> json) {
    return PurchaseDto(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      productId: json['productId'] as String? ?? '',
      tripId: json['tripId'] as String?,
      status: json['status'] as String? ?? 'PENDING',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'BRL',
      mockPaymentId: json['mockPaymentId'] as String?,
      paidAt: json['paidAt'] as String?,
      cancelledAt: json['cancelledAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'productId': productId,
      'tripId': tripId,
      'status': status,
      'amount': amount,
      'currency': currency,
      'mockPaymentId': mockPaymentId,
      'paidAt': paidAt,
      'cancelledAt': cancelledAt,
    };
  }

  PurchaseEntity toEntity() {
    return PurchaseEntity(
      id: id,
      userId: userId,
      productId: productId,
      tripId: tripId,
      status: _mapStatus(status),
      amount: amount,
      currency: currency,
      mockPaymentId: mockPaymentId,
      paidAt: paidAt != null ? DateTime.tryParse(paidAt!) : null,
      cancelledAt: cancelledAt != null ? DateTime.tryParse(cancelledAt!) : null,
    );
  }

  static PurchaseStatus _mapStatus(String st) {
    switch (st.toUpperCase()) {
      case 'PAID':
        return PurchaseStatus.paid;
      case 'CANCELLED':
        return PurchaseStatus.cancelled;
      case 'EXPIRED':
        return PurchaseStatus.expired;
      case 'REFUNDED':
        return PurchaseStatus.refunded;
      case 'PENDING':
      default:
        return PurchaseStatus.pending;
    }
  }
}
