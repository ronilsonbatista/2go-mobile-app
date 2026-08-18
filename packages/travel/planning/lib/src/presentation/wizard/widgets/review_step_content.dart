import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';
import '../../../domain/models/planning_activity_window.dart';
import '../../../domain/models/planning_budget_option.dart';
import '../../../domain/models/planning_destination.dart';
import '../../../domain/models/planning_interest.dart';
import '../../../domain/models/planning_travelers.dart';

class ReviewStepContent extends StatelessWidget {
  final List<PlanningDestination> destinations;
  final PlanningTravelers travelers;
  final List<PlanningInterest> interests;
  final PlanningActivityWindow activityWindow;
  final String? budgetLevel;
  final ValueChanged<int> onEditSection;

  const ReviewStepContent({
    super.key,
    required this.destinations,
    required this.travelers,
    required this.interests,
    required this.activityWindow,
    required this.budgetLevel,
    required this.onEditSection,
  });

  Widget _buildReviewSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required int stepNumber,
    required Widget content,
  }) {
    final theme = Theme.of(context);

    return TwoGoCard(
      child: Padding(
        padding: const EdgeInsets.all(TwoGoSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: TwoGoColors.brandLime),
                const SizedBox(width: TwoGoSpacing.xs),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: TwoGoColors.textPrimary,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => onEditSection(stepNumber),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Editar'),
                  style: TextButton.styleFrom(
                    foregroundColor: TwoGoColors.neutral900,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(50, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
            const SizedBox(height: TwoGoSpacing.xs),
            const TwoGoDivider(),
            const SizedBox(height: TwoGoSpacing.xs),
            content,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final budgetOption = PlanningBudgetOption.fromRaw(budgetLevel);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: TwoGoSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: TwoGoSpacing.sm),
          Text(
            'Revise seu roteiro',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: TwoGoColors.textPrimary,
            ),
          ),
          const SizedBox(height: TwoGoSpacing.xs),
          Text(
            'Confira todas as suas escolhas antes de gerar o roteiro personalizado.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: TwoGoColors.textSecondary,
            ),
          ),
          const SizedBox(height: TwoGoSpacing.md),

          // Section 1: Destinos & Datas
          _buildReviewSection(
            context: context,
            title: 'Destinos & Datas',
            icon: Icons.place_outlined,
            stepNumber: 1,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: destinations.asMap().entries.map((entry) {
                final idx = entry.key;
                final dest = entry.value;
                final nameStr = dest.name.isNotEmpty
                    ? dest.name
                    : 'Destino não selecionado';
                final datesStr =
                    (dest.arrivalDate.isNotEmpty &&
                        dest.departureDate.isNotEmpty)
                    ? '${dest.arrivalDate} às ${dest.arrivalTime} → ${dest.departureDate} às ${dest.departureTime}'
                    : 'Datas pendentes de seleção';

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: idx < destinations.length - 1 ? TwoGoSpacing.xs : 0,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${idx + 1}. ',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: TwoGoColors.neutral900,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nameStr,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: TwoGoColors.textPrimary,
                              ),
                            ),
                            Text(
                              datesStr,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: TwoGoColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: TwoGoSpacing.sm),

          // Section 2: Viajantes
          _buildReviewSection(
            context: context,
            title: 'Viajantes',
            icon: Icons.people_outline,
            stepNumber: 2,
            content: Text(
              '${travelers.total} viajante(s) (${travelers.adults} adulto(s), ${travelers.children} criança(s), ${travelers.elders} idoso(s))',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: TwoGoColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: TwoGoSpacing.sm),

          // Section 3: Interesses
          _buildReviewSection(
            context: context,
            title: 'Interesses',
            icon: Icons.interests_outlined,
            stepNumber: 3,
            content: interests.isNotEmpty
                ? Wrap(
                    spacing: TwoGoSpacing.xs,
                    runSpacing: TwoGoSpacing.xs,
                    children: interests.map<Widget>((interest) {
                      return TwoGoPill(
                        label: interest.label,
                        variant: TwoGoPillVariant.active,
                      );
                    }).toList(),
                  )
                : Text(
                    'Nenhum interesse selecionado',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: TwoGoColors.textSecondary,
                    ),
                  ),
          ),
          const SizedBox(height: TwoGoSpacing.sm),

          // Section 4: Ritmo Diário
          _buildReviewSection(
            context: context,
            title: 'Ritmo Diário',
            icon: Icons.schedule_outlined,
            stepNumber: 4,
            content: Text(
              'Atividades das ${activityWindow.startTime} às ${activityWindow.endTime}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: TwoGoColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: TwoGoSpacing.sm),

          // Section 5: Orçamento
          _buildReviewSection(
            context: context,
            title: 'Perfil Financeiro',
            icon: Icons.attach_money_outlined,
            stepNumber: 5,
            content: Text(
              budgetOption != null
                  ? '${budgetOption.symbol} ${budgetOption.label} — ${budgetOption.subtitle}'
                  : 'Orçamento não definido',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: TwoGoColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: TwoGoSpacing.lg),
        ],
      ),
    );
  }
}
