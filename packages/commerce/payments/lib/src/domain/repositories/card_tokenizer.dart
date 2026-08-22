import '../entities/card_tokenization_result.dart';

abstract class CardTokenizer {
  Future<CardTokenizationResult> tokenizeCard({
    required String publicKey,
    String? cpf,
    int installments = 1,
  });
}
