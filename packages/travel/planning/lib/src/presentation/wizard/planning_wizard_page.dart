import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twogo_design_system/design_system.dart';
import 'package:twogo_places/places.dart';
import '../bloc/planning_wizard_bloc.dart';
import '../bloc/planning_wizard_event.dart';
import '../bloc/planning_wizard_state.dart';
import 'planning_wizard_scaffold.dart';
import 'widgets/destinations_step_content.dart';
import 'widgets/planning_step_placeholder_view.dart';
import 'widgets/travelers_step_content.dart';

class PlanningWizardPage extends StatelessWidget {
  final PlanningWizardBloc? bloc;
  final SearchPlacesUseCase? searchPlacesUseCase;
  final VoidCallback? onExit;

  const PlanningWizardPage({
    super.key,
    this.bloc,
    this.searchPlacesUseCase,
    this.onExit,
  });

  static const List<String> _stepTitles = [
    'Para onde você quer viajar?',
    'Quem vai?',
    'Selecione os interesses que combinam com você.',
    'Defina o horário das atividades',
    'Qual o estilo da viagem?',
    'Tudo pronto para criarmos seu roteiro?',
  ];

  static const List<String> _stepNames = [
    'Onde',
    'Quem vai',
    'Interesses',
    'Horários',
    'Estilo',
    'Revisão',
  ];

  @override
  Widget build(BuildContext context) {
    if (bloc != null) {
      return BlocProvider.value(
        value: bloc!,
        child: _PlanningWizardView(
          searchPlacesUseCase: searchPlacesUseCase,
          onExit: onExit,
        ),
      );
    }
    return _PlanningWizardView(
      searchPlacesUseCase: searchPlacesUseCase,
      onExit: onExit,
    );
  }
}

class _PlanningWizardView extends StatelessWidget {
  final SearchPlacesUseCase? searchPlacesUseCase;
  final VoidCallback? onExit;

  const _PlanningWizardView({this.searchPlacesUseCase, this.onExit});

  void _showConfirmationModal(BuildContext context) {
    TwoGoBottomSheet.show<void>(
      context,
      title: 'Deseja continuar?',
      child: Column(
        children: [
          Text(
            'Após essa etapa, não será possível alterar as informações.',
            textAlign: TextAlign.center,
            style: TwoGoTypography.bodyMedium.copyWith(
              color: TwoGoColors.textSecondary,
            ),
          ),
          const SizedBox(height: TwoGoSpacing.lg),
          TwoGoButton(
            text: 'Criar meu roteiro agora',
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Jornada finalizada com sucesso!'),
                ),
              );
            },
          ),
          const SizedBox(height: TwoGoSpacing.xs),
          TwoGoButton(
            text: 'Cancelar',
            variant: TwoGoButtonVariant.tertiary,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PlanningWizardBloc, PlanningWizardState>(
      listener: (context, state) {
        if (state.status == PlanningWizardStatus.exit) {
          if (onExit != null) {
            onExit!();
          } else {
            Navigator.of(context).maybePop();
          }
        }
      },
      builder: (context, state) {
        if (state.status == PlanningWizardStatus.loading) {
          return const Scaffold(body: Center(child: TwoGoLoadingIndicator()));
        }

        final stepIndex = (state.currentStep - 1).clamp(0, 5);
        final title = PlanningWizardPage._stepTitles[stepIndex];
        final stepName = PlanningWizardPage._stepNames[stepIndex];

        Widget stepBody;
        switch (state.currentStep) {
          case 1:
            stepBody = DestinationsStepContent(
              destinations: state.destinations,
              searchPlacesUseCase: searchPlacesUseCase,
              onDestinationChanged: (dest) {
                context.read<PlanningWizardBloc>().add(
                  UpdateDestinationAtEvent(dest.order, dest),
                );
              },
              onAddDestination: () {
                context.read<PlanningWizardBloc>().add(
                  const AddDestinationEvent(),
                );
              },
              onRemoveDestination: (idx) {
                context.read<PlanningWizardBloc>().add(
                  RemoveDestinationEvent(idx),
                );
              },
            );
            break;
          case 2:
            stepBody = TravelersStepContent(
              travelers: state.travelers,
              onChanged: (updated) {
                context.read<PlanningWizardBloc>().add(
                  UpdateTravelersEvent(updated),
                );
              },
            );
            break;
          default:
            stepBody = PlanningStepPlaceholderView(
              currentStep: state.currentStep,
              stepName: stepName,
            );
            break;
        }

        return PlanningWizardScaffold(
          currentStep: state.currentStep,
          totalSteps: state.totalSteps,
          title: title,
          isSubmitting: state.status == PlanningWizardStatus.submitting,
          isButtonEnabled: state.isCurrentStepValid,
          buttonText: state.currentStep == 6
              ? 'Criar meu roteiro'
              : 'Continuar',
          onBack: () {
            context.read<PlanningWizardBloc>().add(const PreviousStepEvent());
          },
          onNext: () {
            if (state.currentStep == 6) {
              _showConfirmationModal(context);
            } else {
              context.read<PlanningWizardBloc>().add(const NextStepEvent());
            }
          },
          body: stepBody,
        );
      },
    );
  }
}
