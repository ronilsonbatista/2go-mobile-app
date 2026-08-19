import 'package:twogo_core/twogo_core.dart';
import '../domain/models/claim_journey_result.dart';
import '../domain/repositories/planning_repository.dart';

class ClaimPlanningJourneyUseCase {
  final PlanningRepository _repository;

  ClaimPlanningJourneyUseCase(this._repository);

  Future<Result<ClaimJourneyResult>> execute(String journeyId) {
    return _repository.claimJourney(journeyId);
  }
}
