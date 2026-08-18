import 'package:twogo_core/twogo_core.dart';
import '../domain/models/planning_generation_status.dart';
import '../domain/repositories/planning_repository.dart';

class StartPlanningGenerationUseCase {
  final PlanningRepository _repository;

  StartPlanningGenerationUseCase({required PlanningRepository repository})
    : _repository = repository;

  Future<Result<PlanningGenerationStatus>> call(String journeyId) async {
    return _repository.startGeneration(journeyId);
  }
}
