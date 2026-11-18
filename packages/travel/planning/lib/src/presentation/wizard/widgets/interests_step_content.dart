import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';
import '../../../domain/models/planning_interest.dart';
import '../form_course_tokens.dart';
import 'form_asset_placeholder.dart';

class InterestsStepContent extends StatelessWidget {
  final List<PlanningInterest> selectedInterests;
  final ValueChanged<PlanningInterest> onToggleInterest;

  const InterestsStepContent({
    super.key,
    required this.selectedInterests,
    required this.onToggleInterest,
  });

  String _assetName(PlanningInterest interest) {
    switch (interest) {
      case PlanningInterest.art:
        return 'interest-arte';
      case PlanningInterest.gastronomy:
        return 'interest-gastronomia';
      case PlanningInterest.sports:
        return 'interest-esporte';
      case PlanningInterest.architecture:
        return 'interest-arquitetura';
      case PlanningInterest.outdoor:
        return 'interest-outdoor';
      case PlanningInterest.music:
        return 'interest-musica';
      case PlanningInterest.geekCulture:
        return 'interest-geek';
      case PlanningInterest.localHistory:
        return 'interest-historia';
      case PlanningInterest.nature:
        return 'interest-natureza';
    }
  }

  IconData _fallbackIcon(PlanningInterest interest) {
    switch (interest) {
      case PlanningInterest.art:
        return Icons.palette_outlined;
      case PlanningInterest.gastronomy:
        return Icons.restaurant_outlined;
      case PlanningInterest.sports:
        return Icons.sports_soccer_outlined;
      case PlanningInterest.architecture:
        return Icons.account_balance_outlined;
      case PlanningInterest.outdoor:
        return Icons.directions_bike_outlined;
      case PlanningInterest.music:
        return Icons.music_note_outlined;
      case PlanningInterest.geekCulture:
        return Icons.sports_esports_outlined;
      case PlanningInterest.localHistory:
        return Icons.history_edu_outlined;
      case PlanningInterest.nature:
        return Icons.park_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TwoGoSpacing.md),
      child: Column(
        children: [
          for (final interest in PlanningInterest.values) ...[
            _InterestRow(
              label: interest.label,
              assetName: _assetName(interest),
              fallbackIcon: _fallbackIcon(interest),
              selected: selectedInterests.contains(interest),
              onTap: () => onToggleInterest(interest),
            ),
            const SizedBox(height: TwoGoSpacing.sm),
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
    required this.assetName,
    required this.fallbackIcon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String assetName;
  final IconData fallbackIcon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? FormCourseTokens.interestSelectedFill
          : FormCourseTokens.surface,
      borderRadius: BorderRadius.circular(TwoGoRadius.medium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TwoGoRadius.medium),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: TwoGoSpacing.md,
            vertical: TwoGoSpacing.md,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(TwoGoRadius.medium),
            border: Border.all(
              color: selected
                  ? FormCourseTokens.lime
                  : FormCourseTokens.label.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            children: [
              FormAssetPlaceholder(
                assetName: assetName,
                size: 28,
                fallbackIcon: fallbackIcon,
              ),
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
      child: selected
          ? const Icon(Icons.check, size: 16, color: FormCourseTokens.black)
          : null,
    );
  }
}
