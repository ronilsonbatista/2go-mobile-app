import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';
import 'widgets/planning_step_footer.dart';
import 'widgets/planning_step_header.dart';

class PlanningWizardScaffold extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final String title;
  final String? subtitle;
  final Widget body;
  final String buttonText;
  final bool isSubmitting;
  final bool isButtonEnabled;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const PlanningWizardScaffold({
    super.key,
    required this.currentStep,
    this.totalSteps = 6,
    required this.title,
    this.subtitle,
    required this.body,
    this.buttonText = 'Continuar',
    this.isSubmitting = false,
    this.isButtonEnabled = true,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return TwoGoKeyboardAwareScaffold(
      body: SafeArea(
        child: TwoGoCenteredContent(
          maxWidth: 600,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: TwoGoSpacing.md,
                  vertical: TwoGoSpacing.sm,
                ),
                child: PlanningStepHeader(
                  currentStep: currentStep,
                  totalSteps: totalSteps,
                  title: title,
                  subtitle: subtitle,
                  onBack: onBack,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: body,
                ),
              ),
              PlanningStepFooter(
                buttonText: buttonText,
                loading: isSubmitting,
                enabled: isButtonEnabled,
                onPressed: onNext,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
