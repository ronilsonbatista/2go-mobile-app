import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';
import '../../../domain/models/planning_interest.dart';

class InterestsStepContent extends StatelessWidget {
  final List<PlanningInterest> selectedInterests;
  final ValueChanged<PlanningInterest> onToggleInterest;

  const InterestsStepContent({
    super.key,
    required this.selectedInterests,
    required this.onToggleInterest,
  });

  IconData _iconForInterest(PlanningInterest interest) {
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
        return Icons.hiking_outlined;
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
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: TwoGoSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: TwoGoSpacing.sm),
          Text(
            'O que você mais gosta de fazer?',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: TwoGoColors.textPrimary,
            ),
          ),
          const SizedBox(height: TwoGoSpacing.xs),
          Text(
            'Selecione um ou mais interesses para personalizar os passeios do seu roteiro.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: TwoGoColors.textSecondary,
            ),
          ),
          const SizedBox(height: TwoGoSpacing.md),
          Builder(
            builder: (context) {
              final screenWidth = MediaQuery.of(context).size.width;
              final itemWidth =
                  (screenWidth - (TwoGoSpacing.md * 2) - TwoGoSpacing.sm) / 2;

              return Wrap(
                spacing: TwoGoSpacing.sm,
                runSpacing: TwoGoSpacing.sm,
                children: [
                  for (final interest in PlanningInterest.values)
                    Builder(
                      builder: (context) {
                        final isSelected = selectedInterests.contains(interest);

                        return GestureDetector(
                          onTap: () => onToggleInterest(interest),
                          child: Container(
                            width: itemWidth,
                            padding: const EdgeInsets.symmetric(
                              horizontal: TwoGoSpacing.sm,
                              vertical: TwoGoSpacing.sm,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? TwoGoColors.brandLime.withValues(
                                      alpha: 0.15,
                                    )
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
                                Icon(
                                  _iconForInterest(interest),
                                  color: isSelected
                                      ? TwoGoColors.neutral900
                                      : TwoGoColors.textSecondary,
                                  size: 20,
                                ),
                                const SizedBox(width: TwoGoSpacing.xs),
                                Expanded(
                                  child: Text(
                                    interest.label,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: TwoGoColors.textPrimary,
                                    ),
                                  ),
                                ),
                                if (isSelected) ...[
                                  const SizedBox(width: TwoGoSpacing.xxs),
                                  const Icon(
                                    Icons.check_circle,
                                    color: TwoGoColors.neutral900,
                                    size: 16,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: TwoGoSpacing.lg),
        ],
      ),
    );
  }
}
