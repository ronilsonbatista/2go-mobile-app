import 'package:flutter/material.dart';

import 'planning_course_sheet.dart';

/// Course step-6 confirm sheet. POST/finalize only after Continuar.
///
/// Full-bleed edge-to-edge bottom sheet (Form Revisao).
class PlanningConfirmationSheet {
  const PlanningConfirmationSheet._();

  static Future<bool?> show(BuildContext context) {
    return PlanningCourseSheet.show(
      context,
      title: 'Deseja continuar?',
      body: 'Após essa etapa, não será possível alterar as informações.',
      confirmLabel: 'Continuar',
      cancelLabel: 'Cancelar',
      fullBleed: true,
    );
  }
}
