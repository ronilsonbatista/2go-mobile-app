import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

import 'form_course_tokens.dart';
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
    // Plain Scaffold: course layout needs Expanded + pinned footer.
    // TwoGoKeyboardAwareScaffold wraps body in IntrinsicHeight/scroll and
    // cannot host Expanded (breaks goldens / course smoke).
    return Scaffold(
      backgroundColor: FormCourseTokens.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        // TwoGoCenteredContent defaults to horizontal lg (24). Combined with
        // FormCourseTokens.pageGutter that doubled the side inset to ~40pt on
        // iPhone 16 (live Revisao QA). Own gutters via pageGutter only.
        child: TwoGoCenteredContent(
          maxWidth: 600,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: FormCourseTokens.pageGutter,
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
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
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
