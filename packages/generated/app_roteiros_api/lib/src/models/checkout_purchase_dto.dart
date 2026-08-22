enum PaymentMethodType { PIX, CARD }

class CheckoutPurchaseDto {
  final String tripId;
  final PaymentMethodType paymentMethod;
  final String? couponCode;
  final String? cardToken;
  final int? installments;

  const CheckoutPurchaseDto({
    required this.tripId,
    required this.paymentMethod,
    this.couponCode,
    this.cardToken,
    this.installments,
  });

  Map<String, dynamic> toJson() {
    return {
      'tripId': tripId,
      'paymentMethod': paymentMethod.name,
      if (couponCode != null && couponCode!.isNotEmpty) 'couponCode': couponCode,
      if (cardToken != null && cardToken!.isNotEmpty) 'cardToken': cardToken,
      if (installments != null) 'installments': installments,
    };
  }
}
