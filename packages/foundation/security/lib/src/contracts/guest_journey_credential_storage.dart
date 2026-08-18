abstract interface class GuestJourneyCredentialStorage {
  Future<void> saveGuestToken({
    required String journeyId,
    required String guestToken,
  });

  Future<String?> readGuestToken(String journeyId);

  Future<void> clearGuestToken(String journeyId);

  Future<void> clearAllGuestTokens();
}
