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
    } else if (localDraft != null) {
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
          isDirty: localDraft.isDirty,
        ),
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

    final travelers = _resolveTravelers(
      localDraft: matchesJourney ? localDraft : null,
      journey: journey,
    );

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

  /// Local draft only — Core create/POST happens on finalize (course rule).
  Future<void> _createNewJourney(Emitter<PlanningWizardState> emit) async {
    final draft = PlanningDraft(
      currentStep: 1,
      destinations: state.destinations.map((d) => d.toJson()).toList(),
      travelers: state.travelers.toJson(),
      interests: state.interests.map((i) => i.toRaw()).toList(),
      activityWindow: state.activityWindow.toJson(),
      budgetLevel: state.budgetLevel,
      isDirty: true,
    );
    await _draftStorage.saveDraft(draft);
    emit(
      state.copyWith(
        status: PlanningWizardStatus.editing,
        currentStep: 1,
        draft: draft,
        isDirty: true,
      ),
    );
  }

  Future<void> _persistLocalDraft({
    required int currentStep,
    bool isDirty = true,
  }) async {
    final existing = await _draftStorage.readDraft();
    final draft = (existing ?? const PlanningDraft()).copyWith(
      activeJourneyId: state.journey?.id ?? existing?.activeJourneyId,
      currentStep: currentStep,
      destinations: state.destinations.map((d) => d.toJson()).toList(),
      travelers: state.travelers.toJson(),
      interests: state.interests.map((i) => i.toRaw()).toList(),
      activityWindow: state.activityWindow.toJson(),
      budgetLevel: state.budgetLevel,
      isDirty: isDirty,
    );
    await _draftStorage.saveDraft(draft);
  }

  Future<void> _onNextStep(
    NextStepEvent event,
    Emitter<PlanningWizardState> emit,
  ) async {
    if (state.status == PlanningWizardStatus.submitting) return;

    if (!state.isCurrentStepValid) return;

    emit(state.copyWith(status: PlanningWizardStatus.submitting));

    final nextStep = state.returnToReview ? 6 : state.currentStep + 1;
    final clampedNext = nextStep <= state.totalSteps
        ? nextStep
        : state.currentStep;

    // users-defaults: keep answers local through Q&A; no Core PATCH per step.
    await _persistLocalDraft(currentStep: clampedNext);
    final draft = await _draftStorage.readDraft();

    emit(
      state.copyWith(
        status: PlanningWizardStatus.editing,
        currentStep: clampedNext,
        draft: draft,
        returnToReview: false,
        isDirty: true,
      ),
    );
  }

  Future<void> _onAddDestination(
    AddDestinationEvent event,
    Emitter<PlanningWizardState> emit,
  ) async {
    final updated = List<PlanningDestination>.from(state.destinations);

    // Extra destinations also start empty (Selecionar) — user picks dates.
    updated.add(
      PlanningDestination(
        name: '',
        arrivalDate: '',
        arrivalTime: '09:00',
        departureDate: '',
        departureTime: '18:00',
        order: updated.length,
      ),
    );

    emit(state.copyWith(destinations: updated, isDirty: true));
    await _persistLocalDraft(currentStep: state.currentStep);
  }

  Future<void> _onRemoveDestination(
    RemoveDestinationEvent event,
    Emitter<PlanningWizardState> emit,
  ) async {
    if (state.destinations.length <= 1) return;

    final updated = List<PlanningDestination>.from(state.destinations);
    if (event.index >= 0 && event.index < updated.length) {
      updated.removeAt(event.index);
      final reindexed = updated
          .asMap()
          .entries
          .map((entry) => entry.value.copyWith(order: entry.key))
          .toList();
      emit(state.copyWith(destinations: reindexed, isDirty: true));
      await _persistLocalDraft(currentStep: state.currentStep);
    }
  }

  Future<void> _onUpdateDestinationAt(
    UpdateDestinationAtEvent event,
    Emitter<PlanningWizardState> emit,
  ) async {
    final updated = List<PlanningDestination>.from(state.destinations);
    if (event.index >= 0 && event.index < updated.length) {
      updated[event.index] = event.destination.copyWith(order: event.index);
      emit(state.copyWith(destinations: updated, isDirty: true));
      await _persistLocalDraft(currentStep: state.currentStep);
    }
  }

  Future<void> _onUpdateTravelers(
    UpdateTravelersEvent event,
    Emitter<PlanningWizardState> emit,
  ) async {
    emit(state.copyWith(travelers: event.travelers, isDirty: true));
    await _persistLocalDraft(currentStep: state.currentStep);
  }

  Future<void> _onToggleInterest(
    ToggleInterestEvent event,
    Emitter<PlanningWizardState> emit,
  ) async {
    final updated = List<PlanningInterest>.from(state.interests);
    if (updated.contains(event.interest)) {
      updated.remove(event.interest);
    } else {
      updated.add(event.interest);
    }
    emit(state.copyWith(interests: updated, isDirty: true));
    await _persistLocalDraft(currentStep: state.currentStep);
  }

  Future<void> _onUpdateInterests(
    UpdateInterestsEvent event,
    Emitter<PlanningWizardState> emit,
  ) async {
    emit(state.copyWith(interests: event.interests, isDirty: true));
    await _persistLocalDraft(currentStep: state.currentStep);
  }

  Future<void> _onUpdateActivityWindow(
    UpdateActivityWindowEvent event,
    Emitter<PlanningWizardState> emit,
  ) async {
    emit(state.copyWith(activityWindow: event.activityWindow, isDirty: true));
    await _persistLocalDraft(currentStep: state.currentStep);
  }

  Future<void> _onSelectBudgetLevel(
    SelectBudgetLevelEvent event,
    Emitter<PlanningWizardState> emit,
  ) async {
    emit(state.copyWith(budgetLevel: event.budgetLevel, isDirty: true));
    await _persistLocalDraft(currentStep: state.currentStep);
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

  PlanningTravelers _resolveTravelers({
    required PlanningDraft? localDraft,
    GuestJourney? journey,
  }) {
    if (localDraft?.travelers != null) {
      final parsed = PlanningTravelers.fromJson(localDraft!.travelers!);
      // Never leave Age at 0 adultos — product default is 1 adult.
      if (parsed.total == 0) {
        return const PlanningTravelers(adults: 1);
      }
      return parsed;
    }
    final fromJourney = journey?.travelers;
    if (fromJourney != null && fromJourney.total > 0) {
      return fromJourney;
    }
    return state.travelers.total > 0
        ? state.travelers
        : const PlanningTravelers(adults: 1);
  }

  Future<void> _onFinalize(
    FinalizeWizardEvent event,
    Emitter<PlanningWizardState> emit,
  ) async {
    emit(state.copyWith(status: PlanningWizardStatus.submitting));

    try {
      final payloadError = _validateGeneratePayload(state);
      if (payloadError != null) {
        emit(
          state.copyWith(
            status: PlanningWizardStatus.failure,
            errorMessage: payloadError,
          ),
        );
        return;
      }

      await _persistLocalDraft(currentStep: state.currentStep);

      var journeyId = state.journey?.id ?? state.draft?.activeJourneyId;
      if (journeyId == null || journeyId.isEmpty) {
        final createResult = await _createUseCase();
        final created = createResult.getOrNull();
        if (created == null) {
          emit(
            state.copyWith(
              status: PlanningWizardStatus.failure,
              errorMessage:
                  createResult.exceptionOrNull()?.message ??
                  'Não foi possível criar a jornada. Tente novamente.',
            ),
          );
          return;
        }
        journeyId = created.id;
        // createUseCase resets draft metadata — rewrite full local answers.
        await _persistLocalDraft(currentStep: state.currentStep, isDirty: true);
        emit(state.copyWith(journey: created));
      }

      // Single submit path: push full draft, then finalize.
      final saveResult = await _saveUseCase(
        journeyId: journeyId,
        currentStep: state.currentStep,
        destinations: state.destinations,
        travelers: state.travelers,
        interests: state.interests,
        activityWindow: state.activityWindow,
        budgetLevel: state.budgetLevel,
      );

      if (saveResult.isFailure) {
        emit(
          state.copyWith(
            status: PlanningWizardStatus.failure,
            isDirty: true,
            errorMessage:
                saveResult.exceptionOrNull()?.message ??
                'Não foi possível salvar o roteiro. Revise os dados.',
          ),
        );
        return;
      }

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
    } catch (error) {
      // Never leave Continuar spinning — never dump DioException.toString().
      emit(
        state.copyWith(
          status: PlanningWizardStatus.failure,
          errorMessage:
              'Não foi possível gerar o roteiro. Revise os dados e tente novamente.',
        ),
      );
    }
  }

  /// Client-side guard before PATCH/finalize/generate — avoids Core 400 noise.
  static String? _validateGeneratePayload(PlanningWizardState state) {
    if (!state.isStep1Valid) {
      return 'Revise os destinos e as datas da viagem.';
    }
    for (final destination in state.destinations) {
      final placeId = destination.providerPlaceId?.trim() ?? '';
      if (placeId.isEmpty || placeId.startsWith('catalog:')) {
        return 'Selecione um destino válido na busca.';
      }
      if (destination.arrivalTime.trim().isEmpty ||
          destination.departureTime.trim().isEmpty) {
        return 'Informe horário de chegada e partida.';
      }
    }
    if (!state.isStep2Valid) {
      return 'Informe quem vai viajar.';
    }
    if (!state.isStep3Valid) {
      return 'Selecione ao menos um interesse.';
    }
    if (!state.isStep4Valid) {
      return 'Defina um horário de atividades válido (início antes do fim).';
    }
    if (!state.isStep5Valid) {
      return 'Escolha o estilo da viagem.';
    }
    return null;
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
