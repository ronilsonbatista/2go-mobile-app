import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_planning/twogo_planning.dart';

void main() {
  group('Step 4 — Activity Hours Tests', () {
    test('PlanningActivityWindow default is 09:00 to 18:30', () {
      const window = PlanningActivityWindow();
      expect(window.startTime, '09:00');
      expect(window.endTime, '18:30');
    });

    test('isStep4Valid requires startTime < endTime', () {
      const validState = PlanningWizardState(
        activityWindow: PlanningActivityWindow(start: '08:00', end: '20:00'),
      );
      expect(validState.isStep4Valid, true);

      const invalidState = PlanningWizardState(
        activityWindow: PlanningActivityWindow(start: '21:00', end: '09:00'),
      );
      expect(invalidState.isStep4Valid, false);
    });

    test('PlanningActivityWindow serialization to and from JSON', () {
      const window = PlanningActivityWindow(start: '10:00', end: '19:00');
      final json = window.toJson();
      expect(json['startTime'], '10:00');
      expect(json['endTime'], '19:00');

      final restored = PlanningActivityWindow.fromJson(json);
      expect(restored.startTime, '10:00');
      expect(restored.endTime, '19:00');
    });
  });
}
