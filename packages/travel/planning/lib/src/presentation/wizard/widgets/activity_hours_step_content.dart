import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';
import '../../../domain/models/planning_activity_window.dart';

class ActivityHoursStepContent extends StatelessWidget {
  final PlanningActivityWindow activityWindow;
  final ValueChanged<PlanningActivityWindow> onChanged;

  const ActivityHoursStepContent({
    super.key,
    required this.activityWindow,
    required this.onChanged,
  });

  Future<void> _selectTime({
    required BuildContext context,
    required bool isStart,
  }) async {
    final currentStr = isStart
        ? activityWindow.startTime
        : activityWindow.endTime;
    final parts = currentStr.split(':');
    final initialTime = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? (isStart ? 9 : 18),
      minute: int.tryParse(parts[1]) ?? (isStart ? 0 : 30),
    );

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: TwoGoColors.surfacePrimary,
              hourMinuteColor: TwoGoColors.brandLime.withValues(alpha: 0.15),
              hourMinuteTextColor: TwoGoColors.neutral900,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formatted =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';

      if (isStart) {
        onChanged(activityWindow.copyWith(startTime: formatted));
      } else {
        onChanged(activityWindow.copyWith(endTime: formatted));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isValid =
        activityWindow.startTime.compareTo(activityWindow.endTime) < 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: TwoGoSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: TwoGoSpacing.sm),
          Text(
            'Qual o seu ritmo diário?',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: TwoGoColors.textPrimary,
            ),
          ),
          const SizedBox(height: TwoGoSpacing.xs),
          Text(
            'Defina os horários habituais em que você deseja iniciar e terminar as atividades do dia.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: TwoGoColors.textSecondary,
            ),
          ),
          const SizedBox(height: TwoGoSpacing.lg),
          TwoGoCard(
            child: Padding(
              padding: const EdgeInsets.all(TwoGoSpacing.md),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Início das atividades',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: TwoGoColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: TwoGoSpacing.xxs),
                            InkWell(
                              onTap: () =>
                                  _selectTime(context: context, isStart: true),
                              borderRadius: BorderRadius.circular(
                                TwoGoRadius.small,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: TwoGoSpacing.sm,
                                  vertical: TwoGoSpacing.xs,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: TwoGoColors.borderDefault,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    TwoGoRadius.small,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        activityWindow.startTime,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: TwoGoColors.textPrimary,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: TwoGoSpacing.xxs),
                                    Icon(
                                      Icons.access_time,
                                      size: 16,
                                      color: TwoGoColors.textSecondary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: TwoGoSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Fim das atividades',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: TwoGoColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: TwoGoSpacing.xxs),
                            InkWell(
                              onTap: () =>
                                  _selectTime(context: context, isStart: false),
                              borderRadius: BorderRadius.circular(
                                TwoGoRadius.small,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: TwoGoSpacing.sm,
                                  vertical: TwoGoSpacing.xs,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: TwoGoColors.borderDefault,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    TwoGoRadius.small,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        activityWindow.endTime,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: TwoGoColors.textPrimary,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: TwoGoSpacing.xxs),
                                    Icon(
                                      Icons.access_time,
                                      size: 16,
                                      color: TwoGoColors.textSecondary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (!isValid) ...[
                    const SizedBox(height: TwoGoSpacing.sm),
                    Text(
                      'O horário de início deve ser anterior ao horário de término.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: TwoGoColors.feedbackError,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: TwoGoSpacing.lg),
        ],
      ),
    );
  }
}
