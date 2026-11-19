import '../domain/models/planning_destination.dart';
import '../domain/models/planning_draft.dart';
import '../domain/models/planning_travelers.dart';
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

  static const PlanningTravelers _defaultTravelers = PlanningTravelers(
    adults: 1,
    children: 0,
    elders: 0,
  );

  /// Fresh empty Onde (no city / dates) with Age defaulting to 1 adulto.
  /// Used by Home "Criar novo roteiro" so step 1 starts blank.
  Future<PlanningDraft> startEmpty({PlanningDraft? existing}) async {
    final prior = existing ?? await _draftStorage.readDraft();
    final draft = PlanningDraft(
      currentStep: 1,
      destinations: [
        const PlanningDestination(
          name: '',
          arrivalDate: '',
          arrivalTime: '09:00',
          departureDate: '',
          departureTime: '18:00',
          order: 0,
        ).toJson(),
      ],
      travelers: prior?.travelers ?? _defaultTravelers.toJson(),
      interests: prior?.interests,
      activityWindow: prior?.activityWindow,
      budgetLevel: prior?.budgetLevel,
      travelStyle: prior?.travelStyle,
      answersVersion: prior?.answersVersion ?? 1,
      isDirty: true,
    );
    await _draftStorage.saveDraft(draft);
    return draft;
  }

  /// Persists the selected destination as step-1 draft answers.
  ///
  /// Dates stay empty (`Selecionar`) so the user must pick them.
  /// [providerPlaceId] should be the Google Places id from Core
  /// `GET /home/destinations` (never invented from slug).
  Future<PlanningDraft> call({
    required String name,
    String? country,
    String? coverImageUrl,
    String? providerPlaceId,
    DateTime? now,
  }) async {
    final existing = await _draftStorage.readDraft();

    final destination = PlanningDestination(
      providerPlaceId: _nonEmpty(providerPlaceId),
      name: name.trim(),
      city: name.trim().isEmpty ? null : name.trim(),
      country: _nonEmpty(country),
      coverImage: _nonEmpty(coverImageUrl),
      // Empty until the user picks — Onde must not invent dates.
      arrivalDate: '',
      arrivalTime: '09:00',
      departureDate: '',
      departureTime: '18:00',
      order: 0,
    );

    // Fresh selection from Home: keep other answers if any, but clear the
    // guest journey id so we do not PATCH an old session on Next.
    // Age always defaults to 1 adulto when travelers were never set.
    final draft = PlanningDraft(
      currentStep: 1,
      destinations: [destination.toJson()],
      travelers: existing?.travelers ?? _defaultTravelers.toJson(),
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

  static String? _nonEmpty(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }
}
