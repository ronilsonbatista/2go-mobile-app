import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twogo_security/twogo_security.dart';
import '../../../application/claim_planning_journey_use_case.dart';
import '../../../domain/failures/planning_failures.dart';

import '../../../domain/models/post_auth_intent.dart';
import '../../../domain/repositories/planning_draft_storage.dart';
import '../../../domain/repositories/post_auth_intent_storage.dart';
import 'planning_claim_event.dart';
import 'planning_claim_state.dart';

class PlanningClaimBloc extends Bloc<PlanningClaimEvent, PlanningClaimState> {
  final ClaimPlanningJourneyUseCase _claimUseCase;
  final GuestJourneyCredentialStorage _credentialStorage;
  final PlanningDraftStorage _draftStorage;
  final PostAuthIntentStorage _intentStorage;

  PlanningClaimBloc({
    required ClaimPlanningJourneyUseCase claimUseCase,
    required GuestJourneyCredentialStorage credentialStorage,
    required PlanningDraftStorage draftStorage,
    required PostAuthIntentStorage intentStorage,
  })  : _claimUseCase = claimUseCase,
        _credentialStorage = credentialStorage,
        _draftStorage = draftStorage,
        _intentStorage = intentStorage,
        super(const PlanningClaimInitialState()) {
    on<ExecutePlanningClaimEvent>(_onExecuteClaim);
    on<RetryPlanningClaimEvent>(_onRetryClaim);
  }

  Future<void> _onExecuteClaim(
    ExecutePlanningClaimEvent event,
    Emitter<PlanningClaimState> emit,
  ) async {
    if (state is PlanningClaimingState) return;

    emit(PlanningClaimingState(journeyId: event.journeyId));

    final result = await _claimUseCase.execute(event.journeyId);

    if (result.isSuccess) {
      final claimResult = result.getOrNull()!;
      final checkoutIntent = PostAuthIntent(
        type: PostAuthIntentType.resumeCheckout,
        journeyId: claimResult.journeyId,
        productId: event.productId,
        tripId: claimResult.tripId,
        createdAt: DateTime.now(),
      );
      await _intentStorage.saveIntent(checkoutIntent);

      await _credentialStorage.clearGuestToken(event.journeyId);
      await _draftStorage.clearDraft();

      emit(PlanningClaimedState(
        journeyId: claimResult.journeyId,
        tripId: claimResult.tripId,
        nextAction: claimResult.nextAction,
        productId: event.productId,
      ));
    } else {
      final failure = result.exceptionOrNull()!;
      if (failure is GuestJourneyExpiredFailure ||
          failure is GuestJourneyNotFoundFailure) {
        await _credentialStorage.clearGuestToken(event.journeyId);
        await _draftStorage.clearDraft();
        await _intentStorage.clearIntent();
        emit(PlanningClaimFailedState(
          journeyId: event.journeyId,
          failure: failure,
          canRetry: false,
        ));
      } else if (failure is PlanningIncompleteFailure &&
          failure.message.contains('já vinculada')) {
        await _credentialStorage.clearGuestToken(event.journeyId);
        await _intentStorage.clearIntent();
        emit(PlanningClaimFailedState(
          journeyId: event.journeyId,
          failure: failure,
          canRetry: false,
        ));
      } else {
        emit(PlanningClaimFailedState(
          journeyId: event.journeyId,
          failure: failure,
          canRetry: true,
        ));
      }
    }
  }

  Future<void> _onRetryClaim(
    RetryPlanningClaimEvent event,
    Emitter<PlanningClaimState> emit,
  ) async {
    final currentState = state;
    if (currentState is PlanningClaimFailedState && currentState.canRetry) {
      add(ExecutePlanningClaimEvent(
        journeyId: currentState.journeyId,
      ));
    }
  }
}
