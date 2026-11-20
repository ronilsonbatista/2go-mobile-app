import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

import '../../../domain/models/planning_preview.dart';

/// Horizontal day pills — selected black, locked grey + padlock.
class PlanningPreviewDayChips extends StatelessWidget {
  const PlanningPreviewDayChips({
    super.key,
    required this.preview,
    required this.selectedDayNumber,
    required this.onSelectDay,
  });

  final PlanningPreview preview;
  final int selectedDayNumber;
  final ValueChanged<int> onSelectDay;

  @override
  Widget build(BuildContext context) {
    final entries = <_DayEntry>[
      ...preview.visibleDays.map(
        (d) => _DayEntry(
          dayNumber: d.dayNumber,
          date: d.date,
          locked: false,
        ),
      ),
      ...preview.lockedDays.map(
        (d) => _DayEntry(
          dayNumber: d.dayNumber,
          date: d.date,
          locked: true,
        ),
      ),
    ]..sort((a, b) => a.dayNumber.compareTo(b.dayNumber));

    // Pill height ~20pt in design; keep horizontal gap sm (12).
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.zero,
      child: Row(
        children: [
          for (final entry in entries) ...[
            _DayChip(
              label: formatDayChipLabel(entry.date, entry.dayNumber),
              selected: entry.dayNumber == selectedDayNumber,
              locked: entry.locked,
              onTap: () => onSelectDay(entry.dayNumber),
            ),
            const SizedBox(width: TwoGoSpacing.sm),
          ],
        ],
      ),
    );
  }

  /// e.g. `Sáb 25/07` from ISO date; falls back to `Dia N`.
  static String formatDayChipLabel(String? isoDate, int dayNumber) {
    final parsed = isoDate == null ? null : DateTime.tryParse(isoDate.trim());
    if (parsed == null) return 'Dia $dayNumber';
    const weekdays = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    final wd = weekdays[parsed.weekday - 1];
    final dd = parsed.day.toString().padLeft(2, '0');
    final mm = parsed.month.toString().padLeft(2, '0');
    return '$wd $dd/$mm';
  }
}

class _DayEntry {
  const _DayEntry({
    required this.dayNumber,
    required this.date,
    required this.locked,
  });

  final int dayNumber;
  final String? date;
  final bool locked;
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.label,
    required this.selected,
    required this.locked,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? TwoGoColors.neutral900
        : TwoGoColors.neutral100;
    final fg = selected
        ? TwoGoColors.contentInverse
        : TwoGoColors.contentSecondary;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: TwoGoSpacing.sm,
            vertical: TwoGoSpacing.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TwoGoTypography.labelMedium.copyWith(
                  color: fg,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              if (locked) ...[
                const SizedBox(width: TwoGoSpacing.xxs),
                Icon(
                  Icons.lock_rounded,
                  size: 12,
                  color: selected ? TwoGoColors.contentInverse : TwoGoColors.neutral500,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
