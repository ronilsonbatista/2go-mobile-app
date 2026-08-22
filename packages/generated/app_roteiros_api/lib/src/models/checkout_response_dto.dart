import 'checkout_pix_details_dto.dart';
import 'checkout_pricing_dto.dart';
import 'checkout_purchase_dto.dart';

enum CheckoutResponseDtoStatusEnum {
  PENDING,
  PAID,
  CANCELLED,
  EXPIRED,
  REFUNDED,
  CHARGEBACK,
}

class CheckoutResponseDto {
  final String purchaseId;
  final CheckoutResponseDtoStatusEnum status;
  final double amount;
  final String currency;
  final PaymentMethodType paymentMethod;
  final CheckoutPixDetailsDto? pixDetails;
  final CheckoutPricingDto? pricing;

  const CheckoutResponseDto({
    required this.purchaseId,
    required this.status,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    this.pixDetails,
    this.pricing,
  });

  factory CheckoutResponseDto.fromJson(Map<String, dynamic> json) {
    return CheckoutResponseDto(
      purchaseId: json['purchaseId'] as String? ?? '',
      status: CheckoutResponseDtoStatusEnum.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => CheckoutResponseDtoStatusEnum.PENDING,
      ),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'BRL',
      paymentMethod: PaymentMethodType.values.firstWhere(
        (e) => e.name == json['paymentMethod'],
        orElse: () => PaymentMethodType.PIX,
      ),
      pixDetails: json['pixDetails'] != null
          ? CheckoutPixDetailsDto.fromJson(json['pixDetails'] as Map<String, dynamic>)
          : null,
      pricing: json['pricing'] != null
          ? CheckoutPricingDto.fromJson(json['pricing'] as Map<String, dynamic>)
          : null,
    );
  }
}
