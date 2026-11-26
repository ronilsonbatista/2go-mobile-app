import 'package:app_roteiros_api/app_roteiros_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_payments/payments.dart';

void main() {
  group('BillingApiClient', () {
    test('GET /trips/:id/checkout-summary parses unwrapped data', () async {
      String? path;
      final dio = Dio(BaseOptions(baseUrl: 'https://core.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            path = options.path;
            handler.resolve(
              Response<Map<String, dynamic>>(
                requestOptions: options,
                statusCode: 200,
                data: _summaryPayload(),
              ),
            );
          },
        ),
      );

      final client = BillingApiClient(dio);
      final summary = await client.getCheckoutSummary('trip-1');

      expect(path, '/trips/trip-1/checkout-summary');
      expect(summary.tripId, 'trip-1');
      expect(summary.pricing.finalAmount, 99.9);
      expect(summary.pricing.amount, 99.9);
      expect(summary.pricing.days, 7);
      expect(summary.pricing.tier, 'UP_TO_7');
      expect(summary.supportedPaymentMethods, ['PIX', 'CARD']);
    });

    test('POST /trips/:id/checkout-quote sends couponCode', () async {
      String? path;
      dynamic body;
      final dio = Dio(BaseOptions(baseUrl: 'https://core.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            path = options.path;
            body = options.data;
            handler.resolve(
              Response<Map<String, dynamic>>(
                requestOptions: options,
                statusCode: 200,
                data: _summaryPayload(),
              ),
            );
          },
        ),
      );

      final client = BillingApiClient(dio);
      final quote = await client.getCheckoutQuote(
        'trip-1',
        const CheckoutQuoteDto(couponCode: '2GO10'),
      );

      expect(path, '/trips/trip-1/checkout-quote');
      expect(body, {'couponCode': '2GO10'});
      expect(quote.pricing.currency, 'BRL');
    });

    test('POST coupons/validate parses valid:false soft response', () async {
      String? path;
      final dio = Dio(BaseOptions(baseUrl: 'https://core.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            path = options.path;
            handler.resolve(
              Response<Map<String, dynamic>>(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'valid': false,
                  'code': 'INVALID_COUPON',
                  'reason': 'Cupom não encontrado',
                },
              ),
            );
          },
        ),
      );

      final client = BillingApiClient(dio);
      final result = await client.validateCoupon(
        'trip-1',
        couponCode: 'BAD',
      );

      expect(path, '/trips/trip-1/coupons/validate');
      expect(result.valid, isFalse);
      expect(result.reason, 'Cupom não encontrado');
      expect(result.pricing, isNull);
    });

    test('POST /purchases/checkout sends idempotency-key header', () async {
      String? path;
      String? idempotency;
      dynamic body;
      final dio = Dio(BaseOptions(baseUrl: 'https://core.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            path = options.path;
            idempotency = options.headers['idempotency-key'] as String?;
            body = options.data;
            handler.resolve(
              Response<Map<String, dynamic>>(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'purchaseId': 'pur_1',
                  'status': 'PENDING',
                  'amount': 19.99,
                  'currency': 'BRL',
                  'paymentMethod': 'PIX',
                  'pixDetails': {
                    'qrCodeBase64': 'abc',
                    'copyPaste': 'pix-copy',
                    'expiresAt': '2026-11-20T12:30:00.000Z',
                  },
                },
              ),
            );
          },
        ),
      );

      final client = BillingApiClient(dio);
      final checkout = await client.processCheckout(
        const CheckoutPurchaseDto(
          tripId: 'trip-1',
          paymentMethod: PaymentMethodType.PIX,
        ),
        idempotencyKey: 'idem-123',
      );

      expect(path, '/purchases/checkout');
      expect(idempotency, 'idem-123');
      expect(body['tripId'], 'trip-1');
      expect(body['paymentMethod'], 'PIX');
      expect(checkout.purchaseId, 'pur_1');
      expect(checkout.status, CheckoutResponseDtoStatusEnum.PENDING);
      expect(checkout.pixDetails?.copyPaste, 'pix-copy');
    });

    test('POST /purchases/card-intent parses pricing', () async {
      String? path;
      dynamic body;
      final dio = Dio(BaseOptions(baseUrl: 'https://core.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            path = options.path;
            body = options.data;
            handler.resolve(
              Response<Map<String, dynamic>>(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'intentId': 'intent_1',
                  'tripId': 'trip-1',
                  'status': 'READY',
                  'publicKey': 'pk_test',
                  'amount': 99.9,
                  'currency': 'BRL',
                  'pricing': {
                    'originalAmount': 99.9,
                    'discountAmount': 0,
                    'finalAmount': 99.9,
                    'currency': 'BRL',
                    'amount': 99.9,
                    'days': 7,
                    'tier': 'UP_TO_7',
                  },
                },
              ),
            );
          },
        ),
      );

      final client = BillingApiClient(dio);
      final intent = await client.createCardIntent(
        tripId: 'trip-1',
        installments: 1,
      );

      expect(path, '/purchases/card-intent');
      expect(body['tripId'], 'trip-1');
      expect(body['installments'], 1);
      expect(intent.intentId, 'intent_1');
      expect(intent.pricing?.finalAmount, 99.9);
      expect(intent.pricing?.amount, 99.9);
      expect(intent.pricing?.tier, 'UP_TO_7');
    });

    test('POST expire and GET status paths', () async {
      final paths = <String>[];
      final dio = Dio(BaseOptions(baseUrl: 'https://core.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            paths.add('${options.method} ${options.path}');
            final isExpire = options.path.endsWith('/expire');
            handler.resolve(
              Response<Map<String, dynamic>>(
                requestOptions: options,
                statusCode: 200,
                data: isExpire
                    ? {
                        'purchaseId': 'pur_1',
                        'status': 'EXPIRED',
                        'expiredAt': '2026-11-20T12:40:00.000Z',
                      }
                    : {
                        'purchaseId': 'pur_1',
                        'status': 'PAID',
                      },
              ),
            );
          },
        ),
      );

      final client = BillingApiClient(dio);
      final expired = await client.expirePurchase('pur_1');
      final status = await client.getPurchaseStatus('pur_1');

      expect(paths, [
        'POST /purchases/pur_1/expire',
        'GET /purchases/pur_1/status',
      ]);
      expect(expired.status, 'EXPIRED');
      expect(status['status'], 'PAID');
    });

    test('propagates DioException on checkout-summary failure', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://core.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.badResponse,
                response: Response(
                  requestOptions: options,
                  statusCode: 404,
                  data: {
                    'success': false,
                    'code': 'TRIP_NOT_FOUND',
                    'message': 'Viagem não encontrada',
                    'timestamp': '2026-11-20T00:00:00.000Z',
                  },
                ),
              ),
            );
          },
        ),
      );

      final client = BillingApiClient(dio);
      expect(
        () => client.getCheckoutSummary('missing'),
        throwsA(isA<DioException>()),
      );
    });
  });
}

Map<String, dynamic> _summaryPayload() => {
      'tripId': 'trip-1',
      'alreadyUnlocked': false,
      'product': {
        'id': 'prod_1',
        'type': 'ITINERARY_FULL_ACCESS',
        'name': 'Roteiro completo',
      },
      'pricing': {
        'originalAmount': 99.9,
        'discountAmount': 0,
        'finalAmount': 99.9,
        'currency': 'BRL',
        'amount': 99.9,
        'days': 7,
        'tier': 'UP_TO_7',
      },
      'supportedPaymentMethods': ['PIX', 'CARD'],
    };
