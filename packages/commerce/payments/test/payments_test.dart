import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_payments/payments.dart';

void main() {
  group(
    'Payments Package Tests (app-roteiros-core MockPaymentProvider contracts)',
    () {
      late MockPaymentsDataSource mockDataSource;
      late PaymentsRepositoryImpl paymentsRepository;
      late PaymentsCubit paymentsCubit;

      setUp(() {
        mockDataSource = MockPaymentsDataSource();
        paymentsRepository = PaymentsRepositoryImpl(
          remoteDataSource: mockDataSource,
        );
        paymentsCubit = PaymentsCubit(paymentsRepository: paymentsRepository);
      });

      tearDown(() {
        paymentsCubit.dispose();
      });

      test(
        'loadProductsAndPurchases loads active products and purchase history',
        () async {
          await paymentsCubit.loadProductsAndPurchases();

          expect(paymentsCubit.value.status, PaymentsStatus.loaded);
          expect(paymentsCubit.value.products, isNotEmpty);
          expect(
            paymentsCubit.value.products.first.name,
            contains('Paris Premium'),
          );

          expect(paymentsCubit.value.purchases, isNotEmpty);
          expect(paymentsCubit.value.purchases.first.isPaid, isTrue);
        },
      );

      test('processMockPayment creates and confirms purchase', () async {
        await paymentsCubit.loadProductsAndPurchases();
        final product = paymentsCubit.value.products.first;

        final purchase = await paymentsCubit.processMockPayment(
          product.id,
          't123',
        );

        expect(purchase.isPaid, isTrue);
        expect(purchase.mockPaymentId, contains('mock_pay_'));
        expect(paymentsCubit.value.status, PaymentsStatus.loaded);
      });
    },
  );
}
