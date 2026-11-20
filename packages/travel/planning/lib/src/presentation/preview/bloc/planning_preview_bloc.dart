import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../application/get_planning_preview_use_case.dart';
import 'planning_preview_event.dart';
import 'planning_preview_state.dart';

class PlanningPreviewBloc
    extends Bloc<PlanningPreviewEvent, PlanningPreviewState> {
  final GetPlanningPreviewUseCase _getPreviewUseCase;

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

        emit(
          PlanningPreviewLoadedState(
            preview: preview,
            selectedDayNumber: initialDay,
          ),
        );

        // Day-1 preview: paywall only from locked-day chips + upsell banner CTA.
        // Do not auto-open the unlock sheet while the guest explores Day 1.
      },
      (failure) {
        emit(PlanningPreviewErrorState(failure: failure));
      },
    );
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
}
