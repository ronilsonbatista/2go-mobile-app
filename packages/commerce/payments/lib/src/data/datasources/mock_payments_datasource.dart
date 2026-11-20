import 'package:app_roteiros_api/app_roteiros_api.dart';
import '../../domain/entities/applied_coupon.dart';
import '../../domain/entities/card_intent_result.dart';
import '../../domain/entities/checkout_pricing.dart';
import '../../domain/entities/checkout_stub_price.dart';
import '../../domain/entities/coupon_validation_result.dart';
import '../../domain/entities/expire_purchase_result.dart';
import '../models/product_dto.dart';
import '../models/purchase_dto.dart';
import 'payments_remote_datasource.dart';

class MockPaymentsDataSource implements PaymentsRemoteDataSource {
  static const _availability = [
    PaymentMethodAvailabilityDto(
      method: 'PIX',
      available: true,
      status: 'AVAILABLE',
    ),
    PaymentMethodAvailabilityDto(
      method: 'CARD',
      available: true,
      status: 'AVAILABLE',
    ),
    PaymentMethodAvailabilityDto(
      method: 'APPLE_PAY',
      available: false,
      status: 'COMING_SOON',
      reason: 'Apple Pay requer configuração manual',
    ),
    PaymentMethodAvailabilityDto(
      method: 'GOOGLE_PAY',
      available: false,
      status: 'COMING_SOON',
      reason: 'Google Pay requer configuração manual',
    ),
  ];

  final List<ProductDto> _products = const [
    ProductDto(
      id: 'prod_full_access_01',
      name: 'Roteiro Completo Paris Premium',
      description: 'Desbloqueio de todas as atrações, mapas e vouchers',
      type: 'ITINERARY_FULL_ACCESS',
      price: kCheckoutStubOriginalAmount,
      currency: kCheckoutStubCurrency,
      active: true,
    ),
    ProductDto(
      id: 'prod_ai_credits_10',
      name: 'Pacote 10 Créditos de IA',
      description: 'Geração personalizada de roteiros via GPT',
      type: 'AI_CREDITS',
      price: 14.90,
      currency: kCheckoutStubCurrency,
      active: true,
    ),
  ];

  final List<PurchaseDto> _purchases = [
    const PurchaseDto(
      id: 'pur_9910283',
      userId: 'u49a21b3-5e18-4931-8544-a68394848a68',
      productId: 'prod_full_access_01',
      tripId: 't78a9c11-4e92-4110-8b01-f51948381180',
      status: 'PAID',
      amount: kCheckoutStubOriginalAmount,
      currency: kCheckoutStubCurrency,
      mockPaymentId: 'mock_pay_881923',
      paidAt: '2026-08-17T11:45:05.000Z',
    ),
  ];

  CheckoutProductDto get _productDto => const CheckoutProductDto(
        id: 'prod_full_access_01',
        type: 'ITINERARY_FULL_ACCESS',
        name: 'Acesso Completo ao Roteiro 2GO',
        description: 'Desbloqueio definitivo do roteiro premium',
      );

  @override
  Future<List<ProductDto>> getActiveProducts() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _products.where((p) => p.active).toList();
  }

  @override
  Future<List<PurchaseDto>> getMyPurchases() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return List.from(_purchases);
  }

  @override
  Future<CheckoutSummaryResponseDto> getCheckoutSummary(String tripId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return CheckoutSummaryResponseDto(
      tripId: tripId,
      alreadyUnlocked: false,
      product: _productDto,
      pricing: const CheckoutPricingDto(
        originalAmount: kCheckoutStubOriginalAmount,
        discountAmount: 0.0,
        finalAmount: kCheckoutStubOriginalAmount,
        currency: kCheckoutStubCurrency,
      ),
      supportedPaymentMethods: const ['PIX', 'CARD'],
      paymentMethodAvailability: _availability,
    );
  }

  @override
  Future<CheckoutQuoteResponseDto> getCheckoutQuote(
    String tripId, {
    String? couponCode,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final validation = await validateCoupon(
      tripId,
      couponCode: couponCode ?? '',
    );
    if (couponCode != null &&
        couponCode.trim().isNotEmpty &&
        !validation.valid) {
      throw Exception(validation.reason ?? 'Cupom inválido');
    }

    final discount = validation.valid ? (validation.pricing?.discountAmount ?? 0) : 0.0;
    final finalPrice = kCheckoutStubOriginalAmount - discount;

    return CheckoutQuoteResponseDto(
      tripId: tripId,
      alreadyUnlocked: false,
      product: _productDto,
      pricing: CheckoutPricingDto(
        originalAmount: kCheckoutStubOriginalAmount,
        discountAmount: discount,
        finalAmount: finalPrice,
        currency: kCheckoutStubCurrency,
      ),
      coupon: validation.coupon == null
          ? null
          : CheckoutCouponDto(
              code: validation.coupon!.code,
              applied: true,
              discountType: validation.coupon!.discountType,
              discountValue: validation.coupon!.discountValue,
              description: validation.coupon!.description,
            ),
      supportedPaymentMethods: const ['PIX', 'CARD'],
      paymentMethodAvailability: _availability,
    );
  }

  @override
  Future<CouponValidationResult> validateCoupon(
    String tripId, {
    required String couponCode,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final trimmed = couponCode.trim().toUpperCase();
    if (trimmed.isEmpty) {
      return const CouponValidationResult(
        valid: false,
        reason: 'Informe um código de cupom',
        pricing: CheckoutPricing(
          originalAmount: kCheckoutStubOriginalAmount,
          discountAmount: 0,
          finalAmount: kCheckoutStubOriginalAmount,
          currency: kCheckoutStubCurrency,
        ),
      );
    }

    // Layout stub: INVALID / NOPE fail; anything else applies R$ 2,00.
    if (trimmed == 'INVALID' || trimmed == 'NOPE') {
      return CouponValidationResult(
        valid: false,
        code: trimmed,
        reason: 'Cupom inválido',
        pricing: const CheckoutPricing(
          originalAmount: kCheckoutStubOriginalAmount,
          discountAmount: 0,
          finalAmount: kCheckoutStubOriginalAmount,
          currency: kCheckoutStubCurrency,
        ),
      );
    }

    const discount = 2.0;
    return CouponValidationResult(
      valid: true,
      code: trimmed,
      pricing: const CheckoutPricing(
        originalAmount: kCheckoutStubOriginalAmount,
        discountAmount: discount,
        finalAmount: kCheckoutStubOriginalAmount - discount,
        currency: kCheckoutStubCurrency,
      ),
      coupon: AppliedCoupon(
        code: trimmed,
        applied: true,
        discountType: 'FIXED',
        discountValue: discount,
        description: 'Cupom de R\$ 2,00 aplicado',
      ),
    );
  }

  @override
  Future<CheckoutResponseDto> processCheckout({
    required String tripId,
    required String paymentMethod,
    String? couponCode,
    String? cardToken,
    int? installments,
    String? idempotencyKey,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final upper = paymentMethod.toUpperCase();
    final methodEnum = upper == 'CARD' || upper == 'CREDIT_CARD'
        ? PaymentMethodType.CARD
        : upper == 'APPLE_PAY'
            ? PaymentMethodType.APPLE_PAY
            : upper == 'GOOGLE_PAY'
                ? PaymentMethodType.GOOGLE_PAY
                : PaymentMethodType.PIX;

    if (cardToken == 'invalid-card-token') {
      throw Exception('Cartão recusado (mock)');
    }

    final purchaseId = 'pur_${DateTime.now().millisecondsSinceEpoch}';

    return CheckoutResponseDto(
      purchaseId: purchaseId,
      status: methodEnum == PaymentMethodType.CARD
          ? CheckoutResponseDtoStatusEnum.PAID
          : CheckoutResponseDtoStatusEnum.PENDING,
      amount: kCheckoutStubOriginalAmount,
      currency: kCheckoutStubCurrency,
      paymentMethod: methodEnum,
      pixDetails: methodEnum == PaymentMethodType.PIX
          ? CheckoutPixDetailsDto(
              copyPaste:
                  '00020126360014BR.GOV.BCB.PIX0114+5511999999999520400005303986540521.995802BR59132GO TURISMO6008SAO PAULO62070503***6304E2CA',
              qrCodeBase64:
                  'iVBORw0KGgoAAAANSU5EUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
              expiresAt: DateTime.now().add(const Duration(minutes: 5)),
            )
          : null,
      pricing: const CheckoutPricingDto(
        originalAmount: kCheckoutStubOriginalAmount,
        discountAmount: 0.0,
        finalAmount: kCheckoutStubOriginalAmount,
        currency: kCheckoutStubCurrency,
      ),
    );
  }

  @override
  Future<CardIntentResult> createCardIntent({
    required String tripId,
    String? couponCode,
    int? installments,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    var amount = kCheckoutStubOriginalAmount;
    if (couponCode != null && couponCode.trim().isNotEmpty) {
      final validation =
          await validateCoupon(tripId, couponCode: couponCode);
      if (validation.valid && validation.pricing != null) {
        amount = validation.pricing!.finalAmount;
      }
    }
    return CardIntentResult(
      intentId: 'card_intent_mock_${DateTime.now().millisecondsSinceEpoch}',
      tripId: tripId,
      status: 'READY',
      amount: amount,
      currency: kCheckoutStubCurrency,
      clientSecret: 'stub_secret_layout',
      message: 'Stub card intent — use test-card-token no checkout.',
      pricing: CheckoutPricing(
        originalAmount: kCheckoutStubOriginalAmount,
        discountAmount: kCheckoutStubOriginalAmount - amount,
        finalAmount: amount,
        currency: kCheckoutStubCurrency,
      ),
    );
  }

  @override
  Future<ExpirePurchaseResult> expirePurchase(String purchaseId) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return ExpirePurchaseResult(
      purchaseId: purchaseId,
      status: 'EXPIRED',
      expiredAt: DateTime.now().toIso8601String(),
      message: 'Cobrança expirada. Pode iniciar um novo pagamento.',
    );
  }

  @override
  Future<Map<String, dynamic>> getPurchaseStatus(String purchaseId) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return {
      'purchaseId': purchaseId,
      'status': 'PAID',
      'paidAt': DateTime.now().toIso8601String(),
      'premiumUnlocked': true,
    };
  }

  @override
  Future<PurchaseDto> createMockPurchase(
    String productId,
    String? tripId,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final product = _products.firstWhere(
      (p) => p.id == productId,
      orElse: () => _products.first,
    );
    final newId = 'pur_${DateTime.now().millisecondsSinceEpoch}';
    final purchase = PurchaseDto(
      id: newId,
      userId: 'u49a21b3-5e18-4931-8544-a68394848a68',
      productId: productId,
      tripId: tripId,
      status: 'PENDING',
      amount: product.price,
      currency: product.currency,
    );
    _purchases.add(purchase);
    return purchase;
  }

  @override
  Future<PurchaseDto> confirmMockPayment(String purchaseId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final index = _purchases.indexWhere((p) => p.id == purchaseId);
    if (index == -1) throw Exception('Compra não encontrada');

    final old = _purchases[index];
    final confirmed = PurchaseDto(
      id: old.id,
      userId: old.userId,
      productId: old.productId,
      tripId: old.tripId,
      status: 'PAID',
      amount: old.amount,
      currency: old.currency,
      mockPaymentId: 'mock_pay_${DateTime.now().millisecondsSinceEpoch}',
      paidAt: DateTime.now().toIso8601String(),
    );
    _purchases[index] = confirmed;
    return confirmed;
  }
}
