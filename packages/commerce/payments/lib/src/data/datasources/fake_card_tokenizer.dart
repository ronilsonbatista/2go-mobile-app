import '../../domain/entities/card_tokenization_result.dart';
import '../../domain/repositories/card_tokenizer.dart';

class FakeCardTokenizer implements CardTokenizer {
  final CardTokenizationResult? resultToReturn;
  final Exception? exceptionToThrow;

  FakeCardTokenizer({
    this.resultToReturn,
    this.exceptionToThrow,
  });

  @override
  Future<CardTokenizationResult> tokenizeCard({
    required String publicKey,
    String? cpf,
    int installments = 1,
  }) async {
    if (publicKey.isEmpty) {
      throw Exception('Missing Mercado Pago Public Key');
    }
    if (exceptionToThrow != null) {
      throw exceptionToThrow!;
    }
    return resultToReturn ??
        CardTokenizationResult(
          cardToken: 'mp_tok_fake_1234567890',
          paymentMethodId: 'visa',
          issuerId: '310',
          installments: installments,
          last4: '4242',
        );
  }
}
