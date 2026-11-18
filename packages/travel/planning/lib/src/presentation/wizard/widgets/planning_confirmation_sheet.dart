import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

import '../form_course_tokens.dart';

/// Course step-6 confirm dialog. POST/finalize only after Continuar.
class PlanningConfirmationSheet extends StatelessWidget {
  const PlanningConfirmationSheet({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => const PlanningConfirmationSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: FormCourseTokens.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TwoGoRadius.large),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 12, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(false),
                icon: const Icon(TwoGoIcons.close, color: FormCourseTokens.ink),
              ),
            ),
            Text(
              'Deseja continuar?',
              textAlign: TextAlign.center,
              style: TwoGoTypography.headlineSmall.copyWith(
                color: FormCourseTokens.black,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: TwoGoSpacing.md),
            Text(
              'Após essa etapa, não será possível alterar as informações.',
              textAlign: TextAlign.center,
              style: TwoGoTypography.bodyMedium.copyWith(
                color: FormCourseTokens.label,
              ),
            ),
            const SizedBox(height: TwoGoSpacing.lg),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: FormCourseTokens.lime,
                  foregroundColor: FormCourseTokens.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(TwoGoRadius.full),
                  ),
                  textStyle: TwoGoTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: const Text('Continuar'),
              ),
            ),
            const SizedBox(height: TwoGoSpacing.sm),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancelar',
                style: TwoGoTypography.titleMedium.copyWith(
                  color: FormCourseTokens.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
