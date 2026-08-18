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

    test('persists draft across app/storage instance restart', () async {
      final storageScope1 = TwoGoStorage();
      final draftStorageScope1 = PersistentPlanningDraftStorage(
        storage: storageScope1,
      );

      const draftToSave = PlanningDraft(
        activeJourneyId: 'journey_123_persistent',
        currentStep: 2,
        destinations: [
          {
            'providerPlaceId': 'place_paris_001',
            'name': 'Paris, France',
            'order': 0,
          },
        ],
        travelers: {'adults': 2, 'children': 1, 'elders': 0},
      );

      await draftStorageScope1.saveDraft(draftToSave);

      // Simulate disposing scope 1 and re-instantiating new app scope
      final storageScope2 = TwoGoStorage();
      final draftStorageScope2 = PersistentPlanningDraftStorage(
        storage: storageScope2,
      );

      final restoredDraft = await draftStorageScope2.readDraft();

      expect(restoredDraft, isNotNull);
      expect(restoredDraft!.activeJourneyId, 'journey_123_persistent');
      expect(restoredDraft.currentStep, 2);
      expect(restoredDraft.destinations, isNotNull);
      expect(
        restoredDraft.destinations!.first['providerPlaceId'],
        'place_paris_001',
      );
      expect(restoredDraft.travelers!['adults'], 2);
      expect(restoredDraft.travelers!['children'], 1);
    });
  });
}
