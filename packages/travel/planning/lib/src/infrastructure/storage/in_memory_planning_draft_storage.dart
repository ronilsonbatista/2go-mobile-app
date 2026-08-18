import '../../domain/models/planning_draft.dart';
import '../../domain/repositories/planning_draft_storage.dart';

class InMemoryPlanningDraftStorage implements PlanningDraftStorage {
  PlanningDraft? _draft;

  @override
  Future<void> saveDraft(PlanningDraft draft) async {
    _draft = draft;
  }

  @override
  Future<PlanningDraft?> readDraft() async {
    return _draft;
  }

  @override
  Future<void> clearDraft() async {
    _draft = null;
  }
}
