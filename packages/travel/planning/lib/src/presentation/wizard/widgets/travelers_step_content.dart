import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';
import '../../../domain/models/planning_travelers.dart';
import '../form_course_tokens.dart';

class TravelersStepContent extends StatelessWidget {
  final PlanningTravelers travelers;
  final ValueChanged<PlanningTravelers> onChanged;

  const TravelersStepContent({
    super.key,
    required this.travelers,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: FormCourseTokens.pageGutter,
      ),
      child: Column(
        children: [
          _TravelerRow(
            label: 'Adultos',
            subtitle: '13 anos ou mais',
            value: travelers.adults,
            min: 1,
            onChanged: (val) => onChanged(travelers.copyWith(adults: val)),
          ),
          // Course Age PDF: circle-center pitch ≈ 92pt → divider 44 with 48 touch.
          const Divider(
            color: FormCourseTokens.summaryCard,
            height: FormCourseTokens.travelerRowDividerHeight,
          ),
          _TravelerRow(
            label: 'Crianças',
            subtitle: 'Menos de 12 anos',
            value: travelers.children,
            min: 0,
            onChanged: (val) => onChanged(travelers.copyWith(children: val)),
          ),
          const Divider(
            color: FormCourseTokens.summaryCard,
            height: FormCourseTokens.travelerRowDividerHeight,
          ),
          _TravelerRow(
            label: 'Idosos',
            subtitle: 'Mais de 65 anos',
            value: travelers.elders,
            min: 0,
            onChanged: (val) => onChanged(travelers.copyWith(elders: val)),
          ),
          const SizedBox(height: TwoGoSpacing.lg),
        ],
      ),
    );
  }
}

class _TravelerRow extends StatelessWidget {
  const _TravelerRow({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.min,
    required this.onChanged,
  });

  final String label;
  final String subtitle;
  final int value;
  final int min;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return TwoGoCounter(
      label: label,
      subtitle: subtitle,
      value: value,
      min: min,
      onChanged: onChanged,
    );
  }
}
