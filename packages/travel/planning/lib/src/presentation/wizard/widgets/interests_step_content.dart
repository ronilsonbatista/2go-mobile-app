import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';
import '../../../domain/models/planning_interest.dart';
import '../form_course_tokens.dart';

class InterestsStepContent extends StatelessWidget {
  final List<PlanningInterest> selectedInterests;
  final ValueChanged<PlanningInterest> onToggleInterest;

  const InterestsStepContent({
    super.key,
    required this.selectedInterests,
    required this.onToggleInterest,
  });

  /// Course PDF uses system Unicode emoji (no custom assets).
  String _emoji(PlanningInterest interest) {
    switch (interest) {
      case PlanningInterest.art:
        return '🖼️';
      case PlanningInterest.gastronomy:
        return '🍲';
      case PlanningInterest.sports:
        return '⚽';
      case PlanningInterest.architecture:
        return '🏯';
      case PlanningInterest.outdoor:
        return '🚴';
      case PlanningInterest.music:
        return '🎸';
      case PlanningInterest.geekCulture:
        return '👾';
      case PlanningInterest.localHistory:
        return '🏺';
      case PlanningInterest.nature:
        return '🌳';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: FormCourseTokens.pageGutter,
      ),
      child: Column(
        children: [
          for (final interest in PlanningInterest.values) ...[
            _InterestRow(
              label: interest.label,
              emoji: _emoji(interest),
              selected: selectedInterests.contains(interest),
              onTap: () => onToggleInterest(interest),
            ),
            const SizedBox(height: FormCourseTokens.interestRowGap),
          ],
          const SizedBox(height: TwoGoSpacing.lg),
        ],
      ),
    );
  }
}

class _InterestRow extends StatelessWidget {
  const _InterestRow({
    required this.label,
    required this.emoji,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String emoji;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? FormCourseTokens.interestSelectedFill
          : FormCourseTokens.surface,
      borderRadius: BorderRadius.circular(FormCourseTokens.rowCardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(FormCourseTokens.rowCardRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: TwoGoSpacing.md,
            vertical: TwoGoSpacing.md,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(FormCourseTokens.rowCardRadius),
            border: Border.all(
              color: selected
                  ? FormCourseTokens.lime
                  : FormCourseTokens.label.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: TwoGoSpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: TwoGoTypography.titleMedium.copyWith(
                    color: FormCourseTokens.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _InterestCheckbox(selected: selected),
            ],
          ),
        ),
      ),
    );
  }
}

class _InterestCheckbox extends StatelessWidget {
  const _InterestCheckbox({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: selected ? FormCourseTokens.lime : FormCourseTokens.surface,
        borderRadius: BorderRadius.circular(TwoGoRadius.small),
        border: Border.all(
          color: selected ? FormCourseTokens.lime : FormCourseTokens.label,
          width: 1.5,
        ),
      ),
      // Material check — requires app `uses-material-design: true`.
      // Without the font this rendered as a broken green storefront-like glyph.
      child: selected
          ? const Icon(
              Icons.check,
              size: 16,
              color: FormCourseTokens.black,
            )
          : null,
    );
  }
}
