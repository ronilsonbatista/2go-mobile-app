import '../../domain/entities/product_entity.dart';
import '../../domain/entities/purchase_entity.dart';
import '../../domain/repositories/payments_repository.dart';
import '../datasources/payments_remote_datasource.dart';

class PaymentsRepositoryImpl implements PaymentsRepository {
  final PaymentsRemoteDataSource _remoteDataSource;

  PaymentsRepositoryImpl({required PaymentsRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<List<ProductEntity>> getActiveProducts() async {
    final dtos = await _remoteDataSource.getActiveProducts();
    return dtos.map((d) => d.toEntity()).toList();
  }

  @override
  Future<List<PurchaseEntity>> getMyPurchases() async {
    final dtos = await _remoteDataSource.getMyPurchases();
    return dtos.map((d) => d.toEntity()).toList();
  }

  @override
  Future<PurchaseEntity> createMockPurchase({
    required String productId,
    String? tripId,
  }) async {
    final dto = await _remoteDataSource.createMockPurchase(productId, tripId);
    return dto.toEntity();
  }

  @override
  Future<PurchaseEntity> confirmMockPayment(String purchaseId) async {
    final dto = await _remoteDataSource.confirmMockPayment(purchaseId);
    return dto.toEntity();
  }
}
