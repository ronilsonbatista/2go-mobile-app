import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

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
        child: TwoGoButton(
          text: buttonText,
          loading: loading,
          onPressed: enabled && !loading ? onPressed : null,
        ),
      ),
    );
  }
}
