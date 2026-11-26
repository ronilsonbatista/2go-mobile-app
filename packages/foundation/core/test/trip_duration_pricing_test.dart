import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_core/twogo_core.dart';

void main() {
  group('TripDurationPricing.amountForDays', () {
    test('≤7 days → 99,90 / UP_TO_7', () {
      expect(TripDurationPricing.amountForDays(1), 99.90);
      expect(TripDurationPricing.amountForDays(7), 99.90);
      expect(TripDurationPricing.tierForDays(7), TripDurationPricing.tierUpTo7);
    });

    test('8–12 days → 119,90 / FROM_8_TO_12', () {
      expect(TripDurationPricing.amountForDays(8), 119.90);
      expect(TripDurationPricing.amountForDays(12), 119.90);
      expect(
        TripDurationPricing.tierForDays(12),
        TripDurationPricing.tierFrom8To12,
      );
    });

    test('≥13 days → 139,90 / FROM_13', () {
      expect(TripDurationPricing.amountForDays(13), 139.90);
      expect(TripDurationPricing.amountForDays(30), 139.90);
      expect(
        TripDurationPricing.tierForDays(13),
        TripDurationPricing.tierFrom13,
      );
    });
  });

  group('TripDurationPricing.daysFromDateRange', () {
    test('inclusive span', () {
      expect(
        TripDurationPricing.daysFromDateRange('2026-07-25', '2026-07-28'),
        4,
      );
    });
  });

  group('TripDurationPricing.resolveDisplayAmount', () {
    test('prefers Core amount when present', () {
      expect(
        TripDurationPricing.resolveDisplayAmount(days: 10, apiAmount: 119.9),
        119.9,
      );
    });

    test('falls back to local mirror when API amount absent', () {
      expect(
        TripDurationPricing.resolveDisplayAmount(days: 10, apiAmount: null),
        119.90,
      );
    });
  });

  test('formatBrl', () {
    expect(TripDurationPricing.formatBrl(99.9), 'R\$ 99,90');
  });
}
