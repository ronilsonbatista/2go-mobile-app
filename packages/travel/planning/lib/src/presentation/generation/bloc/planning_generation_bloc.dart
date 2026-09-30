import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twogo_core/twogo_core.dart';
import '../../../application/get_planning_generation_status_use_case.dart';
import '../../../application/start_planning_generation_use_case.dart';
import '../../../domain/models/guest_journey_status.dart';
import '../../../domain/models/planning_generation_status.dart';
import 'planning_generation_event.dart';
import 'planning_generation_state.dart';

class PlanningGenerationBloc
    extends Bloc<PlanningGenerationEvent, PlanningGenerationState> {
  static const Duration _initialPollDelay = Duration(seconds: 2);
  static const int _maxPollDelaySeconds = 30;

  final StartPlanningGenerationUseCase _startGenerationUseCase;
  final GetPlanningGenerationStatusUseCase _getStatusUseCase;
  Timer? _pollingTimer;
  bool _pollingActive = false;
  Duration _pollDelay = _initialPollDelay;
  String? _pollingJourneyId;

  @visibleForTesting
  Duration? scheduledPollDelay;

  @visibleForTesting
  bool get isPolling => _pollingActive;

  PlanningGenerationBloc({
    required StartPlanningGenerationUseCase startGenerationUseCase,
    required GetPlanningGenerationStatusUseCase getStatusUseCase,
    PlanningGenerationState initialState = const PlanningGenerationState(),
  }) : _startGenerationUseCase = startGenerationUseCase,
       _getStatusUseCase = getStatusUseCase,
       super(initialState) {
    on<StartGenerationEvent>(_onStartGeneration);
    on<CheckGenerationStatusEvent>(_onCheckStatus);
    on<RetryGenerationEvent>(_onRetry);
    on<AppLifecycleStateChangedEvent>(_onAppLifecycleChanged);
  }

  Future<void> _onStartGeneration(
    StartGenerationEvent event,
    Emitter<PlanningGenerationState> emit,
  ) async {
    emit(
      state.copyWith(
        journeyId: event.journeyId,
        status: PlanningGenerationPageStatus.starting,
        errorMessage: null,
      ),
    );

    final result = await _startGenerationUseCase(event.journeyId);

    result.fold(
      (PlanningGenerationStatus genStatus) {
        emit(
          state.copyWith(
            generationStatus: genStatus,
            status: _mapStatusToPageState(genStatus.status),
          ),
        );
        if (_shouldKeepPolling(genStatus)) {
          _startPolling(event.journeyId);
        } else {
          _stopPolling();
        }
      },
      (AppFailure failure) {
        emit(
          state.copyWith(
            status: PlanningGenerationPageStatus.temporaryNetworkFailure,
            errorMessage: 'Conexão instável. Tentando reconectar...',
          ),
        );
        _startPolling(event.journeyId);
      },
    );
  }

  Future<void> _onCheckStatus(
    CheckGenerationStatusEvent event,
    Emitter<PlanningGenerationState> emit,
  ) async {
    final result = await _getStatusUseCase(event.journeyId);

    result.fold(
      (PlanningGenerationStatus genStatus) {
        final pageStatus = _mapStatusToPageState(genStatus.status);
        emit(
          state.copyWith(
            generationStatus: genStatus,
            status: pageStatus,
            errorMessage: genStatus.isFailed
                ? (genStatus.generationErrorCode ??
                      'Ocorreu um erro ao gerar seu roteiro.')
                : null,
          ),
        );

        if (!_shouldKeepPolling(genStatus)) {
          _stopPolling();
        }
      },
      (AppFailure failure) {
        emit(
          state.copyWith(
            status: PlanningGenerationPageStatus.temporaryNetworkFailure,
            errorMessage: 'Verificando conexão...',
          ),
        );
      },
    );

    if (_pollingActive) {
      _bumpPollDelay();
      _armPollTimer();
    }
  }

  Future<void> _onRetry(
    RetryGenerationEvent event,
    Emitter<PlanningGenerationState> emit,
  ) async {
    if (state.journeyId.isNotEmpty) {
      add(StartGenerationEvent(state.journeyId));
    }
  }

  void _onAppLifecycleChanged(
    AppLifecycleStateChangedEvent event,
    Emitter<PlanningGenerationState> emit,
  ) {
    if (event.state == AppLifecycleState.paused ||
        event.state == AppLifecycleState.detached) {
      _stopPolling();
    } else if (event.state == AppLifecycleState.resumed &&
        state.journeyId.isNotEmpty &&
        state.status != PlanningGenerationPageStatus.previewReady &&
        state.status != PlanningGenerationPageStatus.failed) {
      _startPolling(state.journeyId);
      add(CheckGenerationStatusEvent(state.journeyId));
    }
  }

  bool _shouldKeepPolling(PlanningGenerationStatus genStatus) {
    if (genStatus.isPreviewReady || genStatus.isFailed) return false;
    if (genStatus.status == GuestJourneyStatus.expired) return false;
    return true;
  }

  void _startPolling(String journeyId) {
    _pollingActive = true;
    _pollingJourneyId = journeyId;
    _pollDelay = _initialPollDelay;
    _armPollTimer();
  }

  void _armPollTimer() {
    _pollingTimer?.cancel();
    final journeyId = _pollingJourneyId;
    if (!_pollingActive || journeyId == null || isClosed) {
      scheduledPollDelay = null;
      return;
    }

    final delay = _pollDelay;
    scheduledPollDelay = delay;
    _pollingTimer = Timer(delay, () {
      if (!isClosed && _pollingActive) {
        add(CheckGenerationStatusEvent(journeyId));
      }
    });
  }

  void _bumpPollDelay() {
    final nextSeconds = (_pollDelay.inSeconds * 2).clamp(
      2,
      _maxPollDelaySeconds,
    );
    _pollDelay = Duration(seconds: nextSeconds);
  }

  void _stopPolling() {
    _pollingActive = false;
    _pollingJourneyId = null;
    _pollDelay = _initialPollDelay;
    scheduledPollDelay = null;
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  PlanningGenerationPageStatus _mapStatusToPageState(
    GuestJourneyStatus status,
  ) {
    switch (status) {
      case GuestJourneyStatus.generating:
      case GuestJourneyStatus.unknown:
        return PlanningGenerationPageStatus.generating;
      case GuestJourneyStatus.previewReady:
        return PlanningGenerationPageStatus.previewReady;
      case GuestJourneyStatus.failed:
        return PlanningGenerationPageStatus.failed;
      case GuestJourneyStatus.expired:
        return PlanningGenerationPageStatus.expired;
      default:
        return PlanningGenerationPageStatus.generating;
    }
  }

  @override
  Future<void> close() {
    _stopPolling();
    return super.close();
  }
}
