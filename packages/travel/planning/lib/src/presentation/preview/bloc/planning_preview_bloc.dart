import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../application/get_planning_preview_use_case.dart';
import 'planning_preview_event.dart';
import 'planning_preview_state.dart';

class PlanningPreviewBloc
    extends Bloc<PlanningPreviewEvent, PlanningPreviewState> {
  final GetPlanningPreviewUseCase _getPreviewUseCase;
  Timer? _autoPaywallTimer;

  PlanningPreviewBloc({required GetPlanningPreviewUseCase getPreviewUseCase})
    : _getPreviewUseCase = getPreviewUseCase,
      super(const PlanningPreviewInitialState()) {
    on<FetchPlanningPreviewEvent>(_onFetchPreview);
    on<SelectPreviewDayEvent>(_onSelectDay);
    on<OpenPaywallEvent>(_onOpenPaywall);
    on<DismissPaywallEvent>(_onDismissPaywall);
    on<RequestUnlockEvent>(_onRequestUnlock);
  }

  Future<void> _onFetchPreview(
    FetchPlanningPreviewEvent event,
    Emitter<PlanningPreviewState> emit,
  ) async {
    emit(const PlanningPreviewLoadingState());

    final result = await _getPreviewUseCase(event.journeyId);

    result.fold(
      (preview) {
        final initialDay = preview.visibleDays.isNotEmpty
            ? preview.visibleDays.first.dayNumber
            : 1;

        final loadedState = PlanningPreviewLoadedState(
          preview: preview,
          selectedDayNumber: initialDay,
        );

        emit(loadedState);

        // Auto paywall timer check: if offer available, locked days exist, and not auto opened yet
        if (preview.unlockOffer.available &&
            preview.lockedDays.isNotEmpty &&
            preview.policy.autoPaywallDelaySeconds > 0) {
          _scheduleAutoPaywall(preview.policy.autoPaywallDelaySeconds);
        }
      },
      (failure) {
        emit(PlanningPreviewErrorState(failure: failure));
      },
    );
  }

  void _scheduleAutoPaywall(int delaySeconds) {
    _autoPaywallTimer?.cancel();
    _autoPaywallTimer = Timer(Duration(seconds: delaySeconds), () {
      if (!isClosed && state is PlanningPreviewLoadedState) {
        final current = state as PlanningPreviewLoadedState;
        if (!current.hasAutoOpenedPaywall && !current.isPaywallOpen) {
          add(const OpenPaywallEvent(source: 'AUTO'));
        }
      }
    });
  }

  void _onSelectDay(
    SelectPreviewDayEvent event,
    Emitter<PlanningPreviewState> emit,
  ) {
    if (state is! PlanningPreviewLoadedState) return;
    final current = state as PlanningPreviewLoadedState;

    final isLocked = current.preview.lockedDays.any(
      (d) => d.dayNumber == event.dayNumber,
    );

    if (isLocked) {
      add(const OpenPaywallEvent(source: 'LOCKED_DAY'));
    } else {
      emit(current.copyWith(selectedDayNumber: event.dayNumber));
    }
  }

  void _onOpenPaywall(
    OpenPaywallEvent event,
    Emitter<PlanningPreviewState> emit,
  ) {
    if (state is! PlanningPreviewLoadedState) return;
    final current = state as PlanningPreviewLoadedState;

    emit(
      current.copyWith(
        isPaywallOpen: true,
        paywallSource: event.source,
        hasAutoOpenedPaywall: event.source == 'AUTO'
            ? true
            : current.hasAutoOpenedPaywall,
      ),
    );
  }

  void _onDismissPaywall(
    DismissPaywallEvent event,
    Emitter<PlanningPreviewState> emit,
  ) {
    if (state is! PlanningPreviewLoadedState) return;
    final current = state as PlanningPreviewLoadedState;

    emit(current.copyWith(isPaywallOpen: false, paywallSource: null));
  }

  void _onRequestUnlock(
    RequestUnlockEvent event,
    Emitter<PlanningPreviewState> emit,
  ) {
    if (state is! PlanningPreviewLoadedState) return;
    final current = state as PlanningPreviewLoadedState;
    final offer = current.preview.unlockOffer;

    emit(
      PlanningPreviewUnlockRequestedState(
        journeyId: current.preview.id,
        productId: offer.productId,
        productCode: offer.code,
        price: offer.price,
        currency: offer.currency,
      ),
    );
  }

  @override
  Future<void> close() {
    _autoPaywallTimer?.cancel();
    return super.close();
  }
}
