import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_planning/twogo_planning.dart';
import 'package:twogo_security/twogo_security.dart';

class MemorySecureStorage implements GuestJourneyCredentialStorage {
  final Map<String, String> _data = {};

  @override
  Future<void> saveGuestToken({
    required String journeyId,
    required String guestToken,
  }) async {
    _data[journeyId] = guestToken;
  }

  @override
  Future<String?> readGuestToken(String journeyId) async {
    return _data[journeyId];
  }

  @override
  Future<void> clearGuestToken(String journeyId) async {
    _data.remove(journeyId);
  }

  @override
  Future<void> clearAllGuestTokens() async {
    _data.clear();
  }
}

void main() {
  group('Security & Storage Tests', () {
    test(
      'guestToken is saved in GuestJourneyCredentialStorage and isolated from PlanningDraft',
      () async {
        final credentialStorage = MemorySecureStorage();
        final draftStorage = InMemoryPlanningDraftStorage();

        await credentialStorage.saveGuestToken(
          journeyId: 'j-1',
          guestToken: 'secret-xyz',
        );

        const draft = PlanningDraft(
          activeJourneyId: 'j-1',
          currentStep: 2,
          budgetLevel: 'MEDIUM',
          isDirty: true,
        );
        await draftStorage.saveDraft(draft);

        final readToken = await credentialStorage.readGuestToken('j-1');
        expect(readToken, 'secret-xyz');

        final readDraft = await draftStorage.readDraft();
        expect(readDraft?.activeJourneyId, 'j-1');
        expect(readDraft?.currentStep, 2);

        // Verify PlanningDraft json contains NO token
        final jsonMap = readDraft?.toJson();
        expect(jsonMap?.containsKey('guestToken'), false);
      },
    );

    test('clearGuestToken removes credential correctly', () async {
      final credentialStorage = MemorySecureStorage();
      await credentialStorage.saveGuestToken(
        journeyId: 'j-1',
        guestToken: 'tok-1',
      );

      await credentialStorage.clearGuestToken('j-1');

      final token = await credentialStorage.readGuestToken('j-1');
      expect(token, isNull);
    });
  });
}
