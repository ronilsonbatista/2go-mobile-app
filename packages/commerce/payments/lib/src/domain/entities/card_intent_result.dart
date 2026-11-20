import 'checkout_pricing.dart';

/// Stub card intent from `POST /purchases/card-intent`.
class CardIntentResult {
  final String intentId;
  final String tripId;
  final String status;
  final String? publicKey;
  final double amount;
  final String currency;
  final String? clientSecret;
  final String? expiresAt;
  final String? message;
  final CheckoutPricing? pricing;

  const CardIntentResult({
    required this.intentId,
    required this.tripId,
    required this.status,
    this.publicKey,
    required this.amount,
    required this.currency,
    this.clientSecret,
    this.expiresAt,
    this.message,
    this.pricing,
  });
}
