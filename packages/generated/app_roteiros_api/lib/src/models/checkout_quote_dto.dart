class CheckoutQuoteDto {
  final String? couponCode;

  const CheckoutQuoteDto({this.couponCode});

  Map<String, dynamic> toJson() => {
        if (couponCode != null) 'couponCode': couponCode,
      };
}
