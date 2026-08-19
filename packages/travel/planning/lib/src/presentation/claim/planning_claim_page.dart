import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twogo_design_system/design_system.dart';
import 'bloc/planning_claim_bloc.dart';
import 'bloc/planning_claim_event.dart';
import 'bloc/planning_claim_state.dart';

class PlanningClaimPage extends StatefulWidget {
  final String journeyId;
  final String? productId;
  final PlanningClaimBloc bloc;
  final void Function(String tripId, String nextAction)? onClaimed;

  const PlanningClaimPage({
    super.key,
    required this.journeyId,
    this.productId,
    required this.bloc,
    this.onClaimed,
  });

  @override
  State<PlanningClaimPage> createState() => _PlanningClaimPageState();
}

class _PlanningClaimPageState extends State<PlanningClaimPage> {
  @override
  void initState() {
    super.initState();
    widget.bloc.add(
      ExecutePlanningClaimEvent(
        journeyId: widget.journeyId,
        productId: widget.productId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.bloc,
      child: BlocConsumer<PlanningClaimBloc, PlanningClaimState>(
        listener: (context, state) {
          if (state is PlanningClaimedState) {
            widget.onClaimed?.call(state.tripId, state.nextAction);
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: TwoGoColors.backgroundPrimary,
            body: SafeArea(
              child: TwoGoCenteredContent(
                child: Padding(
                  padding: const EdgeInsets.all(TwoGoSpacing.lg),
                  child: _buildContent(context, state),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, PlanningClaimState state) {
    if (state is PlanningClaimingState || state is PlanningClaimInitialState) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const TwoGoLoadingIndicator(),
          const SizedBox(height: TwoGoSpacing.lg),
          Text(
            'Preparando seu acesso...',
            style: TwoGoTypography.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: TwoGoColors.neutral900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TwoGoSpacing.xs),
          Text(
            'Vinculando seu roteiro personalizado à sua conta 2GO.',
            style: TwoGoTypography.bodyMedium.copyWith(
              color: TwoGoColors.neutral600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    if (state is PlanningClaimFailedState) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: TwoGoColors.error,
          ),
          const SizedBox(height: TwoGoSpacing.md),
          TwoGoStatusMessage(
            title: 'Não foi possível vincular a viagem',
            description: state.failure.message,
          ),
          const SizedBox(height: TwoGoSpacing.lg),
          if (state.canRetry)
            TwoGoButton(
              text: 'Tentar Novamente',
              onPressed: () {
                widget.bloc.add(const RetryPlanningClaimEvent());
              },
            ),
        ],
      );
    }

    if (state is PlanningClaimedState) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            size: 48,
            color: TwoGoColors.brandLimePressed,
          ),
          const SizedBox(height: TwoGoSpacing.md),
          Text(
            'Viagem vinculada!',
            style: TwoGoTypography.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: TwoGoColors.neutral900,
            ),
          ),
          const SizedBox(height: TwoGoSpacing.xs),
          Text(
            'Sua viagem foi salva com sucesso.',
            style: TwoGoTypography.bodyMedium.copyWith(
              color: TwoGoColors.neutral600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}
