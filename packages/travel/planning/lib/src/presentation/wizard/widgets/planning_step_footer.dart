import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

import '../form_course_tokens.dart';

class PlanningStepFooter extends StatelessWidget {
  final String buttonText;
  final bool enabled;
  final bool loading;
  final VoidCallback onPressed;

  const PlanningStepFooter({
    super.key,
    this.buttonText = 'Continuar',
    this.enabled = true,
    this.loading = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: TwoGoSpacing.md,
          vertical: TwoGoSpacing.sm,
        ),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton(
            onPressed: enabled && !loading ? onPressed : null,
            style: FilledButton.styleFrom(
              backgroundColor: FormCourseTokens.lime,
              disabledBackgroundColor: FormCourseTokens.disabledButton,
              foregroundColor: FormCourseTokens.black,
              disabledForegroundColor: FormCourseTokens.disabledLabel,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(TwoGoRadius.full),
              ),
              textStyle: TwoGoTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            child: loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(buttonText),
          ),
        ),
      ),
    );
  }
}
