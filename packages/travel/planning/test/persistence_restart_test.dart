import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twogo_planning/twogo_planning.dart';
import 'package:twogo_storage/twogo_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PersistentPlanningDraftStorage Restart Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test(
      'persists complete questionnaire (Steps 1-5) at Review (Step 6) across app restart',
      () async {
        final storageScope1 = TwoGoStorage();
        final draftStorageScope1 = PersistentPlanningDraftStorage(
          storage: storageScope1,
        );

        const draftToSave = PlanningDraft(
          activeJourneyId: 'journey_123_persistent',
          currentStep: 6,
          destinations: [
            {
              'providerPlaceId': 'place_paris_001',
              'name': 'Paris, France',
              'arrivalDate': '2026-09-01',
              'arrivalTime': '09:00',
              'departureDate': '2026-09-05',
              'departureTime': '18:00',
              'order': 0,
            },
          ],
          travelers: {'adults': 2, 'children': 1, 'elders': 0},
          interests: ['ART', 'GASTRONOMY'],
          activityWindow: {'startTime': '09:00', 'endTime': '19:00'},
          budgetLevel: 'HIGH',
        );

        await draftStorageScope1.saveDraft(draftToSave);

        // Simulate app process restart by re-instantiating storage and draft storage
        final storageScope2 = TwoGoStorage();
        final draftStorageScope2 = PersistentPlanningDraftStorage(
          storage: storageScope2,
        );

        final restoredDraft = await draftStorageScope2.readDraft();

        expect(restoredDraft, isNotNull);
        expect(restoredDraft!.activeJourneyId, 'journey_123_persistent');
        expect(restoredDraft.currentStep, 6);
        expect(
          restoredDraft.destinations!.first['providerPlaceId'],
          'place_paris_001',
        );
        expect(restoredDraft.travelers!['adults'], 2);
        expect(restoredDraft.interests, ['ART', 'GASTRONOMY']);
        expect(restoredDraft.activityWindow!['startTime'], '09:00');
        expect(restoredDraft.budgetLevel, 'HIGH');
      },
    );
  });
}
