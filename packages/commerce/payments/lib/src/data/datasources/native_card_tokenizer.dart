import 'package:flutter/services.dart';
import '../../domain/entities/card_tokenization_result.dart';
import '../../domain/repositories/card_tokenizer.dart';

class NativeCardTokenizer implements CardTokenizer {
  static const MethodChannel _channel =
      MethodChannel('com.twogo.app/payments/card_tokenizer');

  @override
  Future<CardTokenizationResult> tokenizeCard({
    required String publicKey,
    String? cpf,
    int installments = 1,
  }) async {
    if (publicKey.isEmpty) {
      throw Exception('MERCADO_PAGO_PUBLIC_KEY is not configured');
    }

    try {
      final Map<dynamic, dynamic>? response =
          await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'tokenizeCard',
        {
          'publicKey': publicKey,
          'cpf': cpf ?? '',
          'installments': installments,
        },
      );

      if (response == null || response['token'] == null) {
        throw Exception('Card tokenization returned null token');
      }

      return CardTokenizationResult(
        cardToken: response['token'] as String,
        paymentMethodId: response['paymentMethodId'] as String?,
        issuerId: response['issuerId'] as String?,
        installments: (response['installments'] as num?)?.toInt() ?? installments,
        last4: response['last4'] as String?,
      );
    } on PlatformException catch (e) {
      final errorCode = e.code;
      if (errorCode == 'INVALID_CARD_DATA') {
        throw Exception('Dados do cartão inválidos ou incompletos.');
      } else if (errorCode == 'PROVIDER_UNAVAILABLE') {
        throw Exception('Serviço de pagamento temporariamente indisponível.');
      } else if (errorCode == 'IOS_RUNTIME_NOT_VALIDATED') {
        throw Exception('Módulo nativo iOS requer ambiente com Xcode completo.');
      } else if (errorCode == 'CANCELLED') {
        throw Exception('Tokenização cancelada pelo usuário.');
      }
      throw Exception(e.message ?? 'Falha na tokenização do cartão.');
    }
  }
}
