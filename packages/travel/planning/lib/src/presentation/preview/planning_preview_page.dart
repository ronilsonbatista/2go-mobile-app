import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twogo_design_system/design_system.dart';

import '../../domain/models/planning_preview.dart';
import 'bloc/planning_preview_bloc.dart';
import 'bloc/planning_preview_event.dart';
import 'bloc/planning_preview_state.dart';
import 'widgets/planning_timeline_item.dart';
import 'widgets/planning_unlock_sheet.dart';

class PlanningPreviewPage extends StatefulWidget {
  final String journeyId;
  final PlanningPreviewBloc? bloc;
  final void Function(String journeyId, String? productId)? onUnlockRequested;

  const PlanningPreviewPage({
    super.key,
    required this.journeyId,
    this.bloc,
    this.onUnlockRequested,
  });

  @override
  State<PlanningPreviewPage> createState() => _PlanningPreviewPageState();
}

class _PlanningPreviewPageState extends State<PlanningPreviewPage> {
  late final PlanningPreviewBloc _bloc;

  @override
  void initState() {
    super.initState();
    if (widget.bloc != null) {
      _bloc = widget.bloc!;
    } else {
      throw UnimplementedError(
        'PlanningPreviewBloc deve ser injetado via construtor ou BlocProvider',
      );
    }

    _bloc.add(FetchPlanningPreviewEvent(journeyId: widget.journeyId));
  }

  void _showPaywallSheet(
    BuildContext context,
    PlanningPreviewLoadedState state,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => PlanningUnlockSheet(
        offer: state.preview.unlockOffer,
        onUnlockRequested: () {
          Navigator.of(sheetContext).pop();
          _bloc.add(const RequestUnlockEvent());
        },
        onDismiss: () {
          Navigator.of(sheetContext).pop();
          _bloc.add(const DismissPaywallEvent());
        },
      ),
    ).then((_) {
      if (!mounted) return;
      _bloc.add(const DismissPaywallEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocConsumer<PlanningPreviewBloc, PlanningPreviewState>(
        listener: (context, state) {
          if (state is PlanningPreviewLoadedState) {
            if (state.isPaywallOpen) {
              _showPaywallSheet(context, state);
            }
          } else if (state is PlanningPreviewUnlockRequestedState) {
            widget.onUnlockRequested?.call(state.journeyId, state.productId);
          }
        },
        builder: (context, state) {
          if (state is PlanningPreviewLoadingState ||
              state is PlanningPreviewInitialState) {
            return const Scaffold(
              backgroundColor: TwoGoColors.backgroundPrimary,
              body: Center(child: TwoGoLoadingIndicator()),
            );
          }

          if (state is PlanningPreviewErrorState) {
            return Scaffold(
              backgroundColor: TwoGoColors.backgroundPrimary,
              body: TwoGoCenteredContent(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: TwoGoColors.error,
                    ),
                    const SizedBox(height: TwoGoSpacing.md),
                    TwoGoStatusMessage(
                      title: 'Erro ao carregar preview',
                      description:
                          'Não foi possível carregar as informações do seu roteiro.',
                    ),
                    const SizedBox(height: TwoGoSpacing.lg),
                    TwoGoButton(
                      text: 'Tentar Novamente',
                      onPressed: () {
                        _bloc.add(
                          FetchPlanningPreviewEvent(
                            journeyId: widget.journeyId,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is PlanningPreviewLoadedState) {
            final preview = state.preview;
            final summary = preview.summary;
            final selectedDay = state.selectedDayNumber;

            final visibleDayMatch = preview.visibleDays
                .cast<PlanningVisibleDay?>()
                .firstWhere(
                  (d) => d?.dayNumber == selectedDay,
                  orElse: () => null,
                );

            final lockedDayMatch = preview.lockedDays
                .cast<PlanningLockedDay?>()
                .firstWhere(
                  (d) => d?.dayNumber == selectedDay,
                  orElse: () => null,
                );

            final destinationName =
                summary.destinations.isNotEmpty &&
                    summary.destinations[0] is Map
                ? (summary.destinations[0] as Map)['name']?.toString() ??
                      'Sua Viagem'
                : 'Sua Viagem';

            return Scaffold(
              backgroundColor: TwoGoColors.backgroundPrimary,
              body: SafeArea(
                child: Column(
                  children: [
                    // Hero Summary Banner
                    _buildSummaryHero(summary, destinationName),

                    // Day Tabs Header
                    _buildDayTabs(preview, selectedDay),

                    // Main Content (Timeline or Locked Card)
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(TwoGoSpacing.md),
                        child: visibleDayMatch != null
                            ? _buildTimelineList(visibleDayMatch)
                            : _buildLockedDayCard(lockedDayMatch),
                      ),
                    ),

                    // Sticky Bottom Unlock Banner
                    if (preview.unlockOffer.available &&
                        preview.lockedDays.isNotEmpty)
                      _buildBottomUnlockBanner(preview.unlockOffer),
                  ],
                ),
              ),
            );
          }

          return const Scaffold(
            backgroundColor: TwoGoColors.backgroundPrimary,
            body: SizedBox.shrink(),
          );
        },
      ),
    );
  }

  Widget _buildSummaryHero(
    PlanningPreviewSummary summary,
    String destinationName,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(TwoGoSpacing.md),
      decoration: const BoxDecoration(color: TwoGoColors.neutral900),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.flight_takeoff_rounded,
                color: TwoGoColors.brandLime,
                size: 20,
              ),
              const SizedBox(width: TwoGoSpacing.xs),
              Text(
                '2GO PREVIEW',
                style: TwoGoTypography.labelSmall.copyWith(
                  color: TwoGoColors.brandLime,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: TwoGoSpacing.xs),
          Text(
            destinationName,
            style: TwoGoTypography.headlineMedium.copyWith(
              color: TwoGoColors.neutral0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: TwoGoSpacing.xs),
          Text(
            '${summary.totalDays} dias de roteiro personalizado',
            style: TwoGoTypography.bodySmall.copyWith(
              color: TwoGoColors.neutral300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayTabs(PlanningPreview preview, int selectedDayNumber) {
    final totalDaysCount =
        preview.visibleDays.length + preview.lockedDays.length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: TwoGoSpacing.md,
        vertical: TwoGoSpacing.sm,
      ),
      child: Row(
        children: List.generate(totalDaysCount, (idx) {
          final dayNumber = idx + 1;
          final isSelected = dayNumber == selectedDayNumber;
          final isLocked = preview.lockedDays.any(
            (d) => d.dayNumber == dayNumber,
          );

          return Padding(
            padding: const EdgeInsets.only(right: TwoGoSpacing.xs),
            child: ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Dia $dayNumber'),
                  if (isLocked) ...[
                    const SizedBox(width: TwoGoSpacing.xxs),
                    const Icon(
                      Icons.lock_outline_rounded,
                      size: 14,
                      color: TwoGoColors.neutral600,
                    ),
                  ],
                ],
              ),
              selected: isSelected,
              onSelected: (_) {
                _bloc.add(SelectPreviewDayEvent(dayNumber: dayNumber));
              },
              selectedColor: TwoGoColors.neutral800,
              backgroundColor: TwoGoColors.neutral0,
              labelStyle: TextStyle(
                color: isSelected
                    ? TwoGoColors.brandLime
                    : TwoGoColors.neutral900,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTimelineList(PlanningVisibleDay day) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          day.title,
          style: TwoGoTypography.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: TwoGoColors.neutral900,
          ),
        ),
        if (day.description != null && day.description!.isNotEmpty) ...[
          const SizedBox(height: TwoGoSpacing.xs),
          Text(
            day.description!,
            style: TwoGoTypography.bodyMedium.copyWith(
              color: TwoGoColors.neutral700,
            ),
          ),
        ],
        const SizedBox(height: TwoGoSpacing.md),
        ...day.activities.asMap().entries.map(
          (entry) => PlanningTimelineItem(
            activity: entry.value,
            isLast: entry.key == day.activities.length - 1,
          ),
        ),
      ],
    );
  }

  Widget _buildLockedDayCard(PlanningLockedDay? lockedDay) {
    final title = lockedDay?.title ?? 'Dia Bloqueado';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TwoGoSpacing.xl),
      child: TwoGoCard(
        child: Padding(
          padding: const EdgeInsets.all(TwoGoSpacing.xl),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: TwoGoColors.neutral900,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  color: TwoGoColors.brandLime,
                  size: 32,
                ),
              ),
              const SizedBox(height: TwoGoSpacing.md),
              Text(
                title,
                style: TwoGoTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: TwoGoColors.neutral900,
                ),
              ),
              const SizedBox(height: TwoGoSpacing.xs),
              Text(
                'Desbloqueie o acesso completo para visualizar as atividades deste dia.',
                textAlign: TextAlign.center,
                style: TwoGoTypography.bodyMedium.copyWith(
                  color: TwoGoColors.neutral700,
                ),
              ),
              const SizedBox(height: TwoGoSpacing.lg),
              TwoGoButton(
                text: 'Desbloquear Roteiro',
                onPressed: () {
                  _bloc.add(const OpenPaywallEvent(source: 'LOCKED_DAY'));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomUnlockBanner(PlanningUnlockOffer offer) {
    final currencySymbol = offer.currency == 'BRL' ? 'R\$' : offer.currency;
    final formattedPrice =
        '$currencySymbol ${offer.price.toStringAsFixed(2).replaceAll('.', ',')}';

    return Container(
      padding: const EdgeInsets.all(TwoGoSpacing.md),
      decoration: const BoxDecoration(
        color: TwoGoColors.neutral0,
        border: Border(top: BorderSide(color: TwoGoColors.neutral200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Roteiro Completo',
                  style: TwoGoTypography.labelSmall.copyWith(
                    color: TwoGoColors.neutral600,
                  ),
                ),
                Text(
                  formattedPrice,
                  style: TwoGoTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: TwoGoColors.brandLimePressed,
                  ),
                ),
              ],
            ),
          ),
          TwoGoButton(
            text: 'Desbloquear',
            fullWidth: false,
            onPressed: () {
              _bloc.add(const OpenPaywallEvent(source: 'BANNER'));
            },
          ),
        ],
      ),
    );
  }
}
