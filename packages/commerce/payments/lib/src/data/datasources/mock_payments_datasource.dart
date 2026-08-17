import '../models/product_dto.dart';
import '../models/purchase_dto.dart';
import 'payments_remote_datasource.dart';

class MockPaymentsDataSource implements PaymentsRemoteDataSource {
  final List<ProductDto> _products = const [
    ProductDto(
      id: 'prod_full_access_01',
      name: 'Roteiro Completo Paris Premium',
      description: 'Desbloqueio de todas as atrações, mapas e vouchers',
      type: 'ITINERARY_FULL_ACCESS',
      price: 29.90,
      currency: 'BRL',
      active: true,
    ),
    ProductDto(
      id: 'prod_ai_credits_10',
      name: 'Pacote 10 Créditos de IA',
      description: 'Geração personalizada de roteiros via GPT',
      type: 'AI_CREDITS',
      price: 14.90,
      currency: 'BRL',
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
      amount: 29.90,
      currency: 'BRL',
      mockPaymentId: 'mock_pay_881923',
      paidAt: '2026-08-17T11:45:05.000Z',
    ),
  ];

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
