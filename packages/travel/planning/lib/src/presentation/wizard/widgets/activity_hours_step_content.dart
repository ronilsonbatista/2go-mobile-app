import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';
import '../../../domain/models/planning_activity_window.dart';
import '../form_course_tokens.dart';
import 'form_asset_placeholder.dart';

class ActivityHoursStepContent extends StatelessWidget {
  final PlanningActivityWindow activityWindow;
  final ValueChanged<PlanningActivityWindow> onChanged;

  const ActivityHoursStepContent({
    super.key,
    required this.activityWindow,
    required this.onChanged,
  });

  static const _startOptions = [
    '08:00',
    '08:30',
    '09:00',
    '09:30',
    '10:00',
  ];
  static const _endOptions = [
    '18:00',
    '18:30',
    '19:00',
    '19:30',
    '20:00',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TwoGoSpacing.md),
      child: Column(
        children: [
          _HoursCard(
            assetName: 'activity-sun-cloud',
            fallbackIcon: Icons.wb_sunny_outlined,
            title: 'Início das atividades',
            options: _startOptions,
            selected: activityWindow.startTime,
            onSelected: (value) =>
                onChanged(activityWindow.copyWith(startTime: value)),
          ),
          const SizedBox(height: TwoGoSpacing.md),
          _HoursCard(
            assetName: 'activity-moon',
            fallbackIcon: Icons.nightlight_round,
            title: 'Fim das atividades',
            options: _endOptions,
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
    required this.assetName,
    required this.fallbackIcon,
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final String assetName;
  final IconData fallbackIcon;
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
        borderRadius: BorderRadius.circular(TwoGoRadius.large),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FormAssetPlaceholder(
                assetName: assetName,
                size: 22,
                fallbackIcon: fallbackIcon,
              ),
              const SizedBox(width: TwoGoSpacing.sm),
              Text(
                title,
                style: TwoGoTypography.titleMedium.copyWith(
                  color: FormCourseTokens.black,
                  fontWeight: FontWeight.w600,
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
