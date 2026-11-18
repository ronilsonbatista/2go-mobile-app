import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';
import '../../../domain/models/planning_budget_option.dart';
import '../form_course_tokens.dart';

class BudgetStepContent extends StatelessWidget {
  final String? selectedBudgetLevel;
  final ValueChanged<String> onSelectBudgetLevel;

  const BudgetStepContent({
    super.key,
    required this.selectedBudgetLevel,
    required this.onSelectBudgetLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TwoGoSpacing.md),
      child: Column(
        children: [
          for (final option in PlanningBudgetOption.options) ...[
            _StyleRow(
              option: option,
              selected: selectedBudgetLevel == option.rawValue,
              onTap: () => onSelectBudgetLevel(option.rawValue),
            ),
            const SizedBox(height: TwoGoSpacing.sm),
          ],
          const SizedBox(height: TwoGoSpacing.lg),
        ],
      ),
    );
  }
}

class _StyleRow extends StatelessWidget {
  const _StyleRow({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final PlanningBudgetOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: FormCourseTokens.surface,
      borderRadius: BorderRadius.circular(TwoGoRadius.medium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TwoGoRadius.medium),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: TwoGoSpacing.md,
            vertical: TwoGoSpacing.lg,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(TwoGoRadius.medium),
            border: Border.all(
              color: selected
                  ? FormCourseTokens.lime
                  : FormCourseTokens.label.withValues(alpha: 0.25),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              // ASSET_REQUIRED: style-dollar-* — Text placeholder in #3A4088
              Text(
                option.symbol,
                style: TwoGoTypography.titleLarge.copyWith(
                  color: FormCourseTokens.styleDollar,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: TwoGoSpacing.md),
              Expanded(
                child: Text(
                  option.label,
                  style: TwoGoTypography.titleMedium.copyWith(
                    color: FormCourseTokens.label,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(
                TwoGoIcons.chevronRight,
                color: FormCourseTokens.ink,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
