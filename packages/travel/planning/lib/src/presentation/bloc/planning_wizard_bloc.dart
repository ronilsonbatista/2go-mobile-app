import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/create_planning_journey_use_case.dart';
import '../../application/finalize_planning_journey_use_case.dart';
import '../../application/restore_planning_journey_use_case.dart';
import '../../application/save_planning_progress_use_case.dart';
import '../../domain/models/planning_destination.dart';
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
  }) : _createUseCase = createUseCase,
       _restoreUseCase = restoreUseCase,
       _saveUseCase = saveUseCase,
       _finalizeUseCase = finalizeUseCase,
       _draftStorage = draftStorage,
       super(const PlanningWizardState()) {
    on<InitializeWizardEvent>(_onInitialize);
    on<NextStepEvent>(_onNextStep);
    on<PreviousStepEvent>(_onPreviousStep);
    on<GoToStepEvent>(_onGoToStep);
    on<FinalizeWizardEvent>(_onFinalize);
    on<RetrySyncEvent>(_onRetrySync);
    on<AddDestinationEvent>(_onAddDestination);
    on<RemoveDestinationEvent>(_onRemoveDestination);
    on<UpdateDestinationAtEvent>(_onUpdateDestinationAt);
    on<UpdateTravelersEvent>(_onUpdateTravelers);
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
          final restoredDestinations = localDraft?.destinations != null
              ? localDraft!.destinations!
                    .map((e) => PlanningDestination.fromJson(e))
                    .toList()
              : state.destinations;

          final restoredTravelers = localDraft?.travelers != null
              ? PlanningTravelers.fromJson(localDraft!.travelers!)
              : state.travelers;

          emit(
            state.copyWith(
              status: PlanningWizardStatus.editing,
              journey: journey,
              currentStep: journey.currentStep.clamp(1, state.totalSteps),
              draft: localDraft,
              destinations: restoredDestinations,
              travelers: restoredTravelers,
            ),
          );
        },
        (failure) async {
          if (localDraft != null) {
            final restoredDestinations = localDraft.destinations != null
                ? localDraft.destinations!
                      .map((e) => PlanningDestination.fromJson(e))
                      .toList()
                : state.destinations;

            final restoredTravelers = localDraft.travelers != null
                ? PlanningTravelers.fromJson(localDraft.travelers!)
                : state.travelers;

            emit(
              state.copyWith(
                status: PlanningWizardStatus.editing,
                currentStep: localDraft.currentStep.clamp(1, state.totalSteps),
                draft: localDraft,
                destinations: restoredDestinations,
                travelers: restoredTravelers,
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

    final nextStep = state.currentStep + 1;
    final journeyId = state.journey?.id ?? state.draft?.activeJourneyId;

    if (journeyId != null && journeyId.isNotEmpty) {
      final saveResult = await _saveUseCase(
        journeyId: journeyId,
        currentStep: nextStep <= state.totalSteps
            ? nextStep
            : state.currentStep,
        destinations: state.currentStep == 1 ? state.destinations : null,
        travelers: state.currentStep == 2 ? state.travelers : null,
      );

      saveResult.fold(
        (updatedJourney) {
          if (state.currentStep >= state.totalSteps) {
            add(const FinalizeWizardEvent());
          } else {
            emit(
              state.copyWith(
                status: PlanningWizardStatus.editing,
                currentStep: nextStep,
                journey: updatedJourney,
                isDirty: false,
              ),
            );
          }
        },
        (failure) {
          emit(
            state.copyWith(
              status: PlanningWizardStatus.editing,
              currentStep: nextStep <= state.totalSteps
                  ? nextStep
                  : state.currentStep,
              isDirty: true,
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
      // Re-index order 0..N
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

  Future<void> _onRetrySync(
    RetrySyncEvent event,
    Emitter<PlanningWizardState> emit,
  ) async {
    final journeyId = state.journey?.id ?? state.draft?.activeJourneyId;
    if (journeyId == null || journeyId.isEmpty) return;

    emit(state.copyWith(status: PlanningWizardStatus.syncing));

    final result = await _saveUseCase(
      journeyId: journeyId,
      currentStep: state.currentStep,
      destinations: state.currentStep == 1 ? state.destinations : null,
      travelers: state.currentStep == 2 ? state.travelers : null,
    );

    result.fold(
      (updated) => emit(
        state.copyWith(
          status: PlanningWizardStatus.editing,
          journey: updated,
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
}
