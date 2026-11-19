import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';
import '../../../domain/models/planning_activity_window.dart';
import '../form_course_tokens.dart';

class ActivityHoursStepContent extends StatelessWidget {
  final PlanningActivityWindow activityWindow;
  final ValueChanged<PlanningActivityWindow> onChanged;

  const ActivityHoursStepContent({
    super.key,
    required this.activityWindow,
    required this.onChanged,
  });

  /// Início pills: 08:00 → 12:00 (30 min).
  static const startOptions = [
    '08:00',
    '08:30',
    '09:00',
    '09:30',
    '10:00',
    '10:30',
    '11:00',
    '11:30',
    '12:00',
  ];

  /// Fim pills: 18:00 → 22:00 (30 min).
  static const endOptions = [
    '18:00',
    '18:30',
    '19:00',
    '19:30',
    '20:00',
    '20:30',
    '21:00',
    '21:30',
    '22:00',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: FormCourseTokens.pageGutter,
      ),
      child: Column(
        children: [
          _HoursCard(
            emoji: '🌤️',
            title: 'Início das atividades',
            options: startOptions,
            selected: activityWindow.startTime,
            onSelected: (value) =>
                onChanged(activityWindow.copyWith(startTime: value)),
          ),
          const SizedBox(height: TwoGoSpacing.md),
          _HoursCard(
            emoji: '🌙',
            title: 'Fim das atividades',
            options: endOptions,
            selected: activityWindow.endTime,
            onSelected: (value) =>
                onChanged(activityWindow.copyWith(endTime: value)),
          ),
          const SizedBox(height: TwoGoSpacing.lg),
        ],
      ),
    );
  }
}

class _HoursCard extends StatelessWidget {
  const _HoursCard({
    required this.emoji,
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final String emoji;
  final String title;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(TwoGoSpacing.md),
      decoration: BoxDecoration(
        color: FormCourseTokens.surface,
        borderRadius: BorderRadius.circular(FormCourseTokens.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: TwoGoSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TwoGoTypography.titleMedium.copyWith(
                    color: FormCourseTokens.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: TwoGoSpacing.md),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final option in options) ...[
                  _TimeChip(
                    label: option,
                    selected: option == selected,
                    onTap: () => onSelected(option),
                  ),
                  const SizedBox(width: TwoGoSpacing.sm),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? FormCourseTokens.black : FormCourseTokens.surface,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: TwoGoSpacing.md,
            vertical: TwoGoSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? FormCourseTokens.black
                  : FormCourseTokens.label.withValues(alpha: 0.45),
            ),
          ),
          child: Text(
            label,
            style: TwoGoTypography.labelLarge.copyWith(
              color: selected
                  ? FormCourseTokens.surface
                  : FormCourseTokens.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
