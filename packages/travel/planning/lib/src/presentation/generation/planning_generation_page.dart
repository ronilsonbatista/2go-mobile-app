import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twogo_design_system/design_system.dart';
import 'bloc/planning_generation_bloc.dart';
import 'bloc/planning_generation_event.dart';
import 'bloc/planning_generation_state.dart';

class PlanningGenerationPage extends StatefulWidget {
  final String journeyId;
  final PlanningGenerationBloc? bloc;
  final ValueChanged<String>? onPreviewReady;

  const PlanningGenerationPage({
    super.key,
    required this.journeyId,
    this.bloc,
    this.onPreviewReady,
  });

  @override
  State<PlanningGenerationPage> createState() => _PlanningGenerationPageState();
}

class _PlanningGenerationPageState extends State<PlanningGenerationPage>
    with WidgetsBindingObserver {
  late final PlanningGenerationBloc _bloc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.bloc != null) {
      _bloc = widget.bloc!;
    } else {
      throw UnimplementedError(
        'PlanningGenerationBloc deve ser injetado via construtor ou BlocProvider',
      );
    }

    _bloc.add(StartGenerationEvent(widget.journeyId));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _bloc.add(AppLifecycleStateChangedEvent(state));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: TwoGoColors.backgroundPrimary,
        body: SafeArea(
          child: BlocConsumer<PlanningGenerationBloc, PlanningGenerationState>(
            listener: (context, state) {
              if (state.status == PlanningGenerationPageStatus.previewReady) {
                if (widget.onPreviewReady != null) {
                  widget.onPreviewReady!(widget.journeyId);
                }
              }
            },
            builder: (context, state) {
              if (state.status == PlanningGenerationPageStatus.failed) {
                return _buildFailureView(context, state);
              }

              return _buildLoadingView(context, state);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingView(
    BuildContext context,
    PlanningGenerationState state,
  ) {
    final theme = Theme.of(context);
    final isNetworkWarning =
        state.status == PlanningGenerationPageStatus.temporaryNetworkFailure;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(),
          const Center(child: TwoGoLoadingIndicator(size: 56)),
          const SizedBox(height: 32),
          Text(
            'Gerando seu roteiro...',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: TwoGoColors.contentPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Nossa IA está combinando suas preferências, datas e horários para criar uma experiência inesquecível.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: TwoGoColors.contentSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          if (isNetworkWarning) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: TwoGoColors.feedbackWarning.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.wifi_off_rounded,
                    size: 18,
                    color: TwoGoColors.feedbackWarning,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    state.errorMessage ?? 'Conexão instável. Reconectando...',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: TwoGoColors.feedbackWarning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildFailureView(
    BuildContext context,
    PlanningGenerationState state,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(),
          const Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: TwoGoColors.feedbackError,
          ),
          const SizedBox(height: 24),
          Text(
            'Não foi possível gerar seu roteiro agora',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: TwoGoColors.contentPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            state.errorMessage ??
                'Ocorreu uma instabilidade no serviço de Inteligência Artificial. Por favor, tente novamente.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: TwoGoColors.contentSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          TwoGoButton(
            text: 'Tentar novamente',
            variant: TwoGoButtonVariant.primary,
            onPressed: () {
              context.read<PlanningGenerationBloc>().add(
                const RetryGenerationEvent(),
              );
            },
          ),
        ],
      ),
    );
  }
}
