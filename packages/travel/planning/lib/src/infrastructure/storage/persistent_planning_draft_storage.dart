import 'dart:convert';
import 'package:twogo_storage/twogo_storage.dart';
import '../../domain/models/planning_draft.dart';
import '../../domain/repositories/planning_draft_storage.dart';

class PersistentPlanningDraftStorage implements PlanningDraftStorage {
  final TwoGoStorage _storage;
  static const String _storageKey = '2go_planning_draft_v1';

  PersistentPlanningDraftStorage({TwoGoStorage? storage})
    : _storage = storage ?? TwoGoStorage();

  @override
  Future<PlanningDraft?> readDraft() async {
    final jsonString = await _storage.getString(_storageKey);
    if (jsonString == null || jsonString.isEmpty) return null;

    try {
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return PlanningDraft.fromJson(jsonMap);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveDraft(PlanningDraft draft) async {
    final jsonString = jsonEncode(draft.toJson());
    await _storage.setString(_storageKey, jsonString);
  }

  @override
  Future<void> clearDraft() async {
    await _storage.remove(_storageKey);
  }
}
