/// Duration-based itinerary list price (BRL) — mirror of Core `trip-pricing.ts`.
///
/// Tiers (canonical Core rule, 2026-11-26):
/// - ≤7 days → `UP_TO_7` → 99,90
/// - 8–12 days → `FROM_8_TO_12` → 119,90
/// - ≥13 days → `FROM_13` → 139,90
///
/// **Charge amount** must come from Core checkout (`pricing.finalAmount`).
/// Use this helper only for:
/// - Q&A estimate before preview/checkout exists
/// - UI fallback when a stale Core build omits `amount`/`days`/`tier`
///
/// Prefer `unlockOffer.amount` / `pricing.finalAmount` from the API whenever present.
class TripDurationPricing {
  TripDurationPricing._();

  static const String tierUpTo7 = 'UP_TO_7';
  static const String tierFrom8To12 = 'FROM_8_TO_12';
  static const String tierFrom13 = 'FROM_13';

  static const double upTo7Days = 99.90;
  static const double from8To12Days = 119.90;
  static const double from13PlusDays = 139.90;
  static const String currency = 'BRL';

  static String tierForDays(int days) {
    final n = days < 1 ? 1 : days;
    if (n <= 7) return tierUpTo7;
    if (n <= 12) return tierFrom8To12;
    return tierFrom13;
  }

  /// Amount for [days] of trip (minimum 1 day).
  static double amountForDays(int days) {
    switch (tierForDays(days)) {
      case tierFrom8To12:
        return from8To12Days;
      case tierFrom13:
        return from13PlusDays;
      default:
        return upTo7Days;
    }
  }

  /// Inclusive calendar days between ISO dates (yyyy-MM-dd).
  static int daysFromDateRange(String? arrivalIso, String? departureIso) {
    final start = DateTime.tryParse(arrivalIso ?? '');
    final end = DateTime.tryParse(departureIso ?? '');
    if (start == null || end == null) return 1;
    final startDay = DateTime.utc(start.year, start.month, start.day);
    final endDay = DateTime.utc(end.year, end.month, end.day);
    final diff = endDay.difference(startDay).inDays + 1;
    return diff < 1 ? 1 : diff;
  }

  /// Sums per-destination spans (wizard estimate before Core preview).
  static int daysFromDestinationRanges(
    Iterable<(String? arrival, String? departure)> ranges,
  ) {
    var total = 0;
    for (final range in ranges) {
      total += daysFromDateRange(range.$1, range.$2);
    }
    return total < 1 ? 1 : total;
  }

  /// Prefer Core [apiAmount] when present; else local mirror for [days].
  static double resolveDisplayAmount({
    required int days,
    double? apiAmount,
  }) {
    if (apiAmount != null) return apiAmount;
    return amountForDays(days);
  }

  /// Formats BRL as `R$ 99,90`.
  static String formatBrl(double value) {
    final formatted = value.toStringAsFixed(2).replaceAll('.', ',');
    return 'R\$ $formatted';
  }
}
