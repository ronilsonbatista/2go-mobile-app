import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twogo_design_system/design_system.dart';
import 'package:twogo_places/places.dart';
import '../bloc/planning_wizard_bloc.dart';
import '../bloc/planning_wizard_event.dart';
import '../bloc/planning_wizard_state.dart';
import 'planning_wizard_scaffold.dart';
import 'widgets/activity_hours_step_content.dart';
import 'widgets/budget_step_content.dart';
import 'widgets/destinations_step_content.dart';
import 'widgets/interests_step_content.dart';
import 'widgets/planning_confirmation_sheet.dart';
import 'widgets/review_step_content.dart';
import 'widgets/travelers_step_content.dart';

class PlanningWizardPage extends StatelessWidget {
  final PlanningWizardBloc? bloc;
  final SearchPlacesUseCase? searchPlacesUseCase;
  final VoidCallback? onExit;
  final ValueChanged<String>? onReadyToGenerate;

  const PlanningWizardPage({
    super.key,
    this.bloc,
    this.searchPlacesUseCase,
    this.onExit,
    this.onReadyToGenerate,
  });

  static const List<String> _stepTitles = [
    'Para onde você quer viajar?',
    'Quem vai?',
    'Selecione os interesses que combinam com você.',
    'Defina o horário das atividades',
    'Qual o perfil financeiro da viagem?',
    'Tudo pronto para criarmos seu roteiro?',
  ];

  @override
  Widget build(BuildContext context) {
    if (bloc != null) {
      return BlocProvider.value(
        value: bloc!,
        child: _PlanningWizardView(
          searchPlacesUseCase: searchPlacesUseCase,
          onExit: onExit,
          onReadyToGenerate: onReadyToGenerate,
        ),
      );
    }
    return _PlanningWizardView(
      searchPlacesUseCase: searchPlacesUseCase,
      onExit: onExit,
      onReadyToGenerate: onReadyToGenerate,
    );
  }
}

class _PlanningWizardView extends StatelessWidget {
  final SearchPlacesUseCase? searchPlacesUseCase;
  final VoidCallback? onExit;
  final ValueChanged<String>? onReadyToGenerate;

  const _PlanningWizardView({
    this.searchPlacesUseCase,
    this.onExit,
    this.onReadyToGenerate,
  });

  Future<void> _handleFinalizeConfirmation(BuildContext context) async {
    final confirmed = await PlanningConfirmationSheet.show(context);
    if (confirmed == true && context.mounted) {
      context.read<PlanningWizardBloc>().add(const FinalizeWizardEvent());
    }
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

        if (state.status == PlanningWizardStatus.finalized) {
          final journeyId = state.journey?.id ?? state.draft?.activeJourneyId;
          if (journeyId != null && onReadyToGenerate != null) {
            onReadyToGenerate!(journeyId);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Jornada finalizada com sucesso! Pronta para geração por IA.',
                ),
              ),
            );
          }
        }

        if (state.status == PlanningWizardStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: TwoGoColors.feedbackError,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.status == PlanningWizardStatus.loading) {
          return const Scaffold(body: Center(child: TwoGoLoadingIndicator()));
        }

        final stepIndex = (state.currentStep - 1).clamp(0, 5);
        final title = PlanningWizardPage._stepTitles[stepIndex];

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
          case 3:
            stepBody = InterestsStepContent(
              selectedInterests: state.interests,
              onToggleInterest: (interest) {
                context.read<PlanningWizardBloc>().add(
                  ToggleInterestEvent(interest),
                );
              },
            );
            break;
          case 4:
            stepBody = ActivityHoursStepContent(
              activityWindow: state.activityWindow,
              onChanged: (updated) {
                context.read<PlanningWizardBloc>().add(
                  UpdateActivityWindowEvent(updated),
                );
              },
            );
            break;
          case 5:
            stepBody = BudgetStepContent(
              selectedBudgetLevel: state.budgetLevel,
              onSelectBudgetLevel: (level) {
                context.read<PlanningWizardBloc>().add(
                  SelectBudgetLevelEvent(level),
                );
              },
            );
            break;
          case 6:
          default:
            stepBody = ReviewStepContent(
              destinations: state.destinations,
              travelers: state.travelers,
              interests: state.interests,
              activityWindow: state.activityWindow,
              budgetLevel: state.budgetLevel,
              onEditSection: (targetStep) {
                context.read<PlanningWizardBloc>().add(
                  EditSectionEvent(targetStep),
                );
              },
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
              _handleFinalizeConfirmation(context);
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
