import '../domain/models/planning_destination.dart';
import '../domain/models/planning_draft.dart';
import '../domain/repositories/planning_draft_storage.dart';

/// Seeds the local Q&A draft ("users-defaults" / [PlanningDraftStorage])
/// from a Home destination selection.
///
/// Local-only — does **not** create a Core journey or trip. Final Core POST
/// stays at the end of the questions flow.
class SeedHomeDestinationDraftUseCase {
  SeedHomeDestinationDraftUseCase({
    required PlanningDraftStorage draftStorage,
  }) : _draftStorage = draftStorage;

  final PlanningDraftStorage _draftStorage;

  /// Persists the selected destination as step-1 draft answers.
  ///
  /// [providerPlaceId] is intentionally optional: Home carousel ids are
  /// slugs today, not Places ids. Onde Q&A still requires a Places pick
  /// before step-1 is valid until Core links them (Antigravity gap).
  Future<PlanningDraft> call({
    required String name,
    String? country,
    String? coverImageUrl,
    String? providerPlaceId,
    DateTime? now,
  }) async {
    final existing = await _draftStorage.readDraft();
    final clock = now ?? DateTime.now();
    final arrival = clock.add(const Duration(days: 7));
    final departure = arrival.add(const Duration(days: 4));

    final destination = PlanningDestination(
      providerPlaceId: _nonEmpty(providerPlaceId),
      name: name.trim(),
      city: name.trim().isEmpty ? null : name.trim(),
      country: _nonEmpty(country),
      coverImage: _nonEmpty(coverImageUrl),
      arrivalDate: _dateOnly(arrival),
      arrivalTime: '09:00',
      departureDate: _dateOnly(departure),
      departureTime: '18:00',
      order: 0,
    );

    // Fresh selection from Home: keep other answers if any, but clear the
    // guest journey id so we do not PATCH an old session on Next.
    final draft = PlanningDraft(
      currentStep: 1,
      destinations: [destination.toJson()],
      travelers: existing?.travelers,
      interests: existing?.interests,
      activityWindow: existing?.activityWindow,
      budgetLevel: existing?.budgetLevel,
      travelStyle: existing?.travelStyle,
      answersVersion: existing?.answersVersion ?? 1,
      isDirty: true,
    );

    await _draftStorage.saveDraft(draft);
    return draft;
  }

  static String _dateOnly(DateTime value) =>
      value.toIso8601String().split('T').first;

  static String? _nonEmpty(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }
}
