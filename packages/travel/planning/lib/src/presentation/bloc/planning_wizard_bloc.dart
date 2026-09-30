import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/create_planning_journey_use_case.dart';
import '../../application/finalize_planning_journey_use_case.dart';
import '../../application/restore_planning_journey_use_case.dart';
import '../../application/save_planning_progress_use_case.dart';
import '../../domain/models/guest_journey.dart';
import '../../domain/models/planning_activity_window.dart';
import '../../domain/models/planning_destination.dart';
import '../../domain/models/planning_draft.dart';
import '../../domain/models/planning_interest.dart';
import '../../domain/models/planning_travelers.dart';
import '../../domain/repositories/planning_draft_storage.dart';
import 'planning_wizard_event.dart';
import 'planning_wizard_state.dart';

class PlanningWizardBloc
    extends Bloc<PlanningWizardEvent, PlanningWizardState> {
  final CreatePlanningJourneyUseCase _createUseCase;
  final RestorePlanningJourneyUseCase _restoreUseCase;
  final SavePlanningProgressUseCase _saveUseCase;
  final FinalizePlanningJourneyUseCase _finalizeUseCase;
  final PlanningDraftStorage _draftStorage;

  PlanningWizardBloc({
    required CreatePlanningJourneyUseCase createUseCase,
    required RestorePlanningJourneyUseCase restoreUseCase,
    required SavePlanningProgressUseCase saveUseCase,
    required FinalizePlanningJourneyUseCase finalizeUseCase,
    required PlanningDraftStorage draftStorage,
    PlanningWizardState? initialState,
  }) : _createUseCase = createUseCase,
       _restoreUseCase = restoreUseCase,
       _saveUseCase = saveUseCase,
       _finalizeUseCase = finalizeUseCase,
       _draftStorage = draftStorage,
       super(initialState ?? const PlanningWizardState()) {
    on<InitializeWizardEvent>(_onInitialize);
    on<NextStepEvent>(_onNextStep);
    on<PreviousStepEvent>(_onPreviousStep);
    on<GoToStepEvent>(_onGoToStep);
    on<FinalizeWizardEvent>(_onFinalize);
    on<AddDestinationEvent>(_onAddDestination);
    on<RemoveDestinationEvent>(_onRemoveDestination);
    on<UpdateDestinationAtEvent>(_onUpdateDestinationAt);
    on<UpdateTravelersEvent>(_onUpdateTravelers);
    on<ToggleInterestEvent>(_onToggleInterest);
    on<UpdateInterestsEvent>(_onUpdateInterests);
    on<UpdateActivityWindowEvent>(_onUpdateActivityWindow);
    on<SelectBudgetLevelEvent>(_onSelectBudgetLevel);
    on<EditSectionEvent>(_onEditSection);
  }

  Future<void> _onInitialize(
    InitializeWizardEvent event,
    Emitter<PlanningWizardState> emit,
  ) async {
    emit(state.copyWith(status: PlanningWizardStatus.loading));

    final localDraft = await _draftStorage.readDraft();
    final targetJourneyId = event.journeyId ?? localDraft?.activeJourneyId;

    if (targetJourneyId != null && targetJourneyId.isNotEmpty) {
      final restoreResult = await _restoreUseCase(targetJourneyId);
      await restoreResult.fold(
        (journey) async {
          final restored = _answersFromDraftOrJourney(
            localDraft: localDraft,
            journey: journey,
          );
          final restoredBudgetLevel =
              (localDraft?.activeJourneyId == journey.id
                  ? localDraft?.budgetLevel
                  : null) ??
              journey.budgetLevel ??
              state.budgetLevel;

          emit(
            state.copyWith(
              status: PlanningWizardStatus.editing,
              journey: journey,
              currentStep: journey.currentStep.clamp(1, state.totalSteps),
              draft: await _draftStorage.readDraft() ?? localDraft,
              destinations: restored.destinations,
              travelers: restored.travelers,
              interests: restored.interests,
              activityWindow: restored.activityWindow,
              budgetLevel: restoredBudgetLevel,
            ),
          );
        },
        (failure) async {
          if (localDraft != null) {
            final restored = _answersFromDraftOrJourney(localDraft: localDraft);

            emit(
              state.copyWith(
                status: PlanningWizardStatus.editing,
                currentStep: localDraft.currentStep.clamp(1, state.totalSteps),
                draft: localDraft,
                destinations: restored.destinations,
                travelers: restored.travelers,
                interests: restored.interests,
                activityWindow: restored.activityWindow,
                budgetLevel: localDraft.budgetLevel ?? state.budgetLevel,
                isDirty: true,
              ),
            );
          } else {
            await _createNewJourney(emit);
          }
        },
      );
    } else {
      await _createNewJourney(emit);
    }
  }

  _RestoredPlanningAnswers _answersFromDraftOrJourney({
    required PlanningDraft? localDraft,
    GuestJourney? journey,
  }) {
    final matchesJourney =
        journey == null || localDraft?.activeJourneyId == journey.id;

    final destinations =
        localDraft != null && matchesJourney && localDraft.destinations != null
        ? localDraft.destinations!.map(PlanningDestination.fromJson).toList()
        : (journey?.destinations ?? state.destinations);

    final travelers =
        localDraft != null && matchesJourney && localDraft.travelers != null
        ? PlanningTravelers.fromJson(localDraft.travelers!)
        : (journey?.travelers ?? state.travelers);

    final interests =
        localDraft != null && matchesJourney && localDraft.interests != null
        ? PlanningInterest.parseList(localDraft.interests!)
        : (journey?.interests ?? state.interests);

    final activityWindow =
        localDraft != null &&
            matchesJourney &&
            localDraft.activityWindow != null
        ? PlanningActivityWindow.fromJson(localDraft.activityWindow!)
        : (journey?.activityWindow ?? state.activityWindow);

    return _RestoredPlanningAnswers(
      destinations: destinations,
      travelers: travelers,
      interests: interests,
      activityWindow: activityWindow,
    );
  }

  Future<void> _createNewJourney(Emitter<PlanningWizardState> emit) async {
    final createResult = await _createUseCase();
    createResult.fold(
      (journey) {
        emit(
          state.copyWith(
            status: PlanningWizardStatus.editing,
            journey: journey,
            currentStep: 1,
          ),
        );
      },
      (failure) {
        emit(
          state.copyWith(
            status: PlanningWizardStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
    );
  }

  Future<void> _onNextStep(
    NextStepEvent event,
    Emitter<PlanningWizardState> emit,
  ) async {
    if (state.status == PlanningWizardStatus.submitting) return;

    if (!state.isCurrentStepValid) return;

    emit(state.copyWith(status: PlanningWizardStatus.submitting));

    final nextStep = state.returnToReview ? 6 : state.currentStep + 1;
    final journeyId = state.journey?.id ?? state.draft?.activeJourneyId;

    if (journeyId != null && journeyId.isNotEmpty) {
      final saveResult = await _saveUseCase(
        journeyId: journeyId,
        currentStep: nextStep <= state.totalSteps
            ? nextStep
            : state.currentStep,
        destinations: state.currentStep == 1 ? state.destinations : null,
        travelers: state.currentStep == 2 ? state.travelers : null,
        interests: state.currentStep == 3 ? state.interests : null,
        activityWindow: state.currentStep == 4 ? state.activityWindow : null,
        budgetLevel: state.currentStep == 5 ? state.budgetLevel : null,
      );

      saveResult.fold(
        (updatedJourney) {
          if (state.currentStep >= state.totalSteps && !state.returnToReview) {
            add(const FinalizeWizardEvent());
          } else {
            emit(
              state.copyWith(
                status: PlanningWizardStatus.editing,
                currentStep: nextStep,
                journey: updatedJourney,
                returnToReview: false,
                isDirty: false,
              ),
            );
          }
        },
        (failure) {
          emit(
            state.copyWith(
              status: PlanningWizardStatus.failure,
              isDirty: true,
              errorMessage: failure.message,
            ),
          );
        },
      );
    } else {
      emit(
        state.copyWith(
          status: PlanningWizardStatus.editing,
          currentStep: nextStep <= state.totalSteps
              ? nextStep
              : state.currentStep,
          returnToReview: false,
        ),
      );
    }
  }

  void _onAddDestination(
    AddDestinationEvent event,
    Emitter<PlanningWizardState> emit,
  ) {
    final updated = List<PlanningDestination>.from(state.destinations);
    final lastDest = updated.isNotEmpty ? updated.last : null;

    DateTime nextArrival = DateTime.now().add(const Duration(days: 7));
    if (lastDest != null && lastDest.departureDate.isNotEmpty) {
      final parsedDep = DateTime.tryParse(lastDest.departureDate);
      if (parsedDep != null) {
        nextArrival = parsedDep.add(const Duration(days: 1));
      }
    }
    final nextDeparture = nextArrival.add(const Duration(days: 4));

    updated.add(
      PlanningDestination(
        name: '',
        arrivalDate: nextArrival.toIso8601String().split('T').first,
        arrivalTime: '09:00',
        departureDate: nextDeparture.toIso8601String().split('T').first,
        departureTime: '18:00',
        order: updated.length,
      ),
    );

    emit(state.copyWith(destinations: updated));
  }

  void _onRemoveDestination(
    RemoveDestinationEvent event,
    Emitter<PlanningWizardState> emit,
  ) {
    if (state.destinations.length <= 1) return;

    final updated = List<PlanningDestination>.from(state.destinations);
    if (event.index >= 0 && event.index < updated.length) {
      updated.removeAt(event.index);
      final reindexed = updated
          .asMap()
          .entries
          .map((entry) => entry.value.copyWith(order: entry.key))
          .toList();
      emit(state.copyWith(destinations: reindexed));
    }
  }

  void _onUpdateDestinationAt(
    UpdateDestinationAtEvent event,
    Emitter<PlanningWizardState> emit,
  ) {
    final updated = List<PlanningDestination>.from(state.destinations);
    if (event.index >= 0 && event.index < updated.length) {
      updated[event.index] = event.destination.copyWith(order: event.index);
      emit(state.copyWith(destinations: updated));
    }
  }

  void _onUpdateTravelers(
    UpdateTravelersEvent event,
    Emitter<PlanningWizardState> emit,
  ) {
    emit(state.copyWith(travelers: event.travelers));
  }

  void _onToggleInterest(
    ToggleInterestEvent event,
    Emitter<PlanningWizardState> emit,
  ) {
    final updated = List<PlanningInterest>.from(state.interests);
    if (updated.contains(event.interest)) {
      updated.remove(event.interest);
    } else {
      updated.add(event.interest);
    }
    emit(state.copyWith(interests: updated));
  }

  void _onUpdateInterests(
    UpdateInterestsEvent event,
    Emitter<PlanningWizardState> emit,
  ) {
    emit(state.copyWith(interests: event.interests));
  }

  void _onUpdateActivityWindow(
    UpdateActivityWindowEvent event,
    Emitter<PlanningWizardState> emit,
  ) {
    emit(state.copyWith(activityWindow: event.activityWindow));
  }

  void _onSelectBudgetLevel(
    SelectBudgetLevelEvent event,
    Emitter<PlanningWizardState> emit,
  ) {
    emit(state.copyWith(budgetLevel: event.budgetLevel));
  }

  void _onEditSection(
    EditSectionEvent event,
    Emitter<PlanningWizardState> emit,
  ) {
    emit(
      state.copyWith(
        currentStep: event.targetStep.clamp(1, state.totalSteps),
        returnToReview: true,
      ),
    );
  }

  Future<void> _onFinalize(
    FinalizeWizardEvent event,
    Emitter<PlanningWizardState> emit,
  ) async {
    final journeyId = state.journey?.id ?? state.draft?.activeJourneyId;
    if (journeyId == null || journeyId.isEmpty) return;

    emit(state.copyWith(status: PlanningWizardStatus.submitting));

    final result = await _finalizeUseCase(journeyId);
    result.fold(
      (finalizedJourney) => emit(
        state.copyWith(
          status: PlanningWizardStatus.finalized,
          journey: finalizedJourney,
          isDirty: false,
        ),
      ),
      (failure) => emit(
        state.copyWith(
          status: PlanningWizardStatus.failure,
          errorMessage: failure.message,
        ),
      ),
    );
  }

  void _onPreviousStep(
    PreviousStepEvent event,
    Emitter<PlanningWizardState> emit,
  ) {
    if (state.currentStep > 1) {
      emit(
        state.copyWith(
          status: PlanningWizardStatus.editing,
          currentStep: state.currentStep - 1,
        ),
      );
    } else {
      emit(state.copyWith(status: PlanningWizardStatus.exit));
    }
  }

  void _onGoToStep(GoToStepEvent event, Emitter<PlanningWizardState> emit) {
    final targetStep = event.step.clamp(1, state.totalSteps);
    emit(
      state.copyWith(
        status: PlanningWizardStatus.editing,
        currentStep: targetStep,
      ),
    );
  }
}

class _RestoredPlanningAnswers {
  final List<PlanningDestination> destinations;
  final PlanningTravelers travelers;
  final List<PlanningInterest> interests;
  final PlanningActivityWindow activityWindow;

  const _RestoredPlanningAnswers({
    required this.destinations,
    required this.travelers,
    required this.interests,
    required this.activityWindow,
  });
}
