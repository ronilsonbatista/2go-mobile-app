import 'package:twogo_core/twogo_core.dart';
import '../domain/models/planning_preview.dart';
import '../domain/repositories/planning_repository.dart';

class GetPlanningPreviewUseCase {
  final PlanningRepository _repository;

  const GetPlanningPreviewUseCase(this._repository);

  Future<Result<PlanningPreview>> call(String journeyId) {
    return _repository.getPreview(journeyId);
  }
}
