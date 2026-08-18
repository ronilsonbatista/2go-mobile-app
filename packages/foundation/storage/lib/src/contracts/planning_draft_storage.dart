import '../models/planning_draft.dart';

abstract interface class PlanningDraftStorage {
  Future<void> saveDraft(PlanningDraft draft);
  Future<PlanningDraft?> readDraft();
  Future<void> clearDraft();
}
