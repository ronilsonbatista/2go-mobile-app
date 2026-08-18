import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';
import '../../../domain/models/planning_budget_option.dart';

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
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: TwoGoSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: TwoGoSpacing.sm),
          Text(
            'Qual o perfil financeiro da viagem?',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: TwoGoColors.textPrimary,
            ),
          ),
          const SizedBox(height: TwoGoSpacing.xs),
          Text(
            'Defina a faixa de orçamento desejada para direcionar as sugestões de hospedagem, gastronomia e passeios.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: TwoGoColors.textSecondary,
            ),
          ),
          const SizedBox(height: TwoGoSpacing.md),
          Column(
            children: [
              for (
                int index = 0;
                index < PlanningBudgetOption.options.length;
                index++
              ) ...[
                if (index > 0) const SizedBox(height: TwoGoSpacing.sm),
                Builder(
                  builder: (context) {
                    final option = PlanningBudgetOption.options[index];
                    final isSelected = selectedBudgetLevel == option.rawValue;

                    return GestureDetector(
                      onTap: () => onSelectBudgetLevel(option.rawValue),
                      child: Container(
                        padding: const EdgeInsets.all(TwoGoSpacing.md),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? TwoGoColors.brandLime.withValues(alpha: 0.12)
                              : TwoGoColors.surfacePrimary,
                          borderRadius: BorderRadius.circular(
                            TwoGoRadius.medium,
                          ),
                          border: Border.all(
                            color: isSelected
                                ? TwoGoColors.brandLime
                                : TwoGoColors.borderDefault,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: TwoGoSpacing.sm,
                                vertical: TwoGoSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? TwoGoColors.brandLime
                                    : TwoGoColors.surfaceSecondary,
                                borderRadius: BorderRadius.circular(
                                  TwoGoRadius.small,
                                ),
                              ),
                              child: Text(
                                option.symbol,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? TwoGoColors.neutral900
                                      : TwoGoColors.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: TwoGoSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    option.label,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? TwoGoColors.neutral900
                                              : TwoGoColors.textPrimary,
                                        ),
                                  ),
                                  const SizedBox(height: TwoGoSpacing.xxs),
                                  Text(
                                    option.subtitle,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: TwoGoColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: TwoGoSpacing.xs),
                            Icon(
                              isSelected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              color: isSelected
                                  ? TwoGoColors.neutral900
                                  : TwoGoColors.textSecondary,
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
          const SizedBox(height: TwoGoSpacing.lg),
        ],
      ),
    );
  }
}
