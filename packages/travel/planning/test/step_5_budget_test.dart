import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_planning/twogo_planning.dart';

void main() {
  group('Step 5 — Budget Level & Semantic Mapping Tests', () {
    test(
      'PlanningBudgetOption correctly maps raw values to labels and symbols',
      () {
        final low = PlanningBudgetOption.fromRaw('LOW');
        expect(low?.symbol, '\$');
        expect(low?.label, 'Econômica');

        final med = PlanningBudgetOption.fromRaw('MEDIUM');
        expect(med?.symbol, '\$\$');
        expect(med?.label, 'Confortável');

        final high = PlanningBudgetOption.fromRaw('HIGH');
        expect(high?.symbol, '\$\$\$');
        expect(high?.label, 'Premium');

        final premium = PlanningBudgetOption.fromRaw('PREMIUM');
        expect(premium?.symbol, '\$\$\$\$');
        expect(premium?.label, 'Luxuosa');
      },
    );

    test(
      'CRITICAL RULE: Premium budget level maps to HIGH, NEVER to CULTURAL or TravelStyle',
      () {
        final option = PlanningBudgetOption.fromRaw('HIGH');
        expect(option?.rawValue, 'HIGH');
        expect(option?.label, 'Premium');
        expect(option?.rawValue, isNot(equals('CULTURAL')));
      },
    );

    test('isStep5Valid requires non-null budgetLevel', () {
      const emptyState = PlanningWizardState(budgetLevel: null);
      expect(emptyState.isStep5Valid, false);

      const validState = PlanningWizardState(budgetLevel: 'HIGH');
      expect(validState.isStep5Valid, true);
    });
  });
}
