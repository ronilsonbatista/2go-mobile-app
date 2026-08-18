import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_planning/twogo_planning.dart';

void main() {
  group('Step 3 — Interests Tests', () {
    test('PlanningInterest labels are correctly formatted in Portuguese', () {
      expect(PlanningInterest.art.label, 'Arte');
      expect(PlanningInterest.gastronomy.label, 'Gastronomia');
      expect(PlanningInterest.sports.label, 'Esporte');
      expect(PlanningInterest.architecture.label, 'Arquitetura');
      expect(PlanningInterest.outdoor.label, 'Atividades ao ar livre');
      expect(PlanningInterest.music.label, 'Música');
      expect(PlanningInterest.geekCulture.label, 'Cultura geek');
      expect(PlanningInterest.localHistory.label, 'História local');
      expect(PlanningInterest.nature.label, 'Natureza');
    });

    test('isStep3Valid requires at least 1 selected interest', () {
      const stateEmpty = PlanningWizardState(interests: []);
      expect(stateEmpty.isStep3Valid, false);

      const stateSelected = PlanningWizardState(
        interests: [PlanningInterest.art, PlanningInterest.gastronomy],
      );
      expect(stateSelected.isStep3Valid, true);
    });

    test('ToggleInterestEvent toggles interest selection correctly', () {
      var state = const PlanningWizardState(interests: [PlanningInterest.art]);

      // Toggle off
      final updatedOff = List<PlanningInterest>.from(state.interests);
      if (updatedOff.contains(PlanningInterest.art)) {
        updatedOff.remove(PlanningInterest.art);
      }
      state = state.copyWith(interests: updatedOff);
      expect(state.interests.contains(PlanningInterest.art), false);

      // Toggle on
      final updatedOn = List<PlanningInterest>.from(state.interests);
      if (!updatedOn.contains(PlanningInterest.nature)) {
        updatedOn.add(PlanningInterest.nature);
      }
      state = state.copyWith(interests: updatedOn);
      expect(state.interests.contains(PlanningInterest.nature), true);
    });
  });
}
