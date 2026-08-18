import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

class PlanningConfirmationSheet extends StatelessWidget {
  const PlanningConfirmationSheet({super.key});

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const PlanningConfirmationSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TwoGoBottomSheet(
      title: 'Deseja continuar?',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Após essa etapa, não será possível alterar as informações do questionário.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: TwoGoColors.textSecondary,
            ),
          ),
          const SizedBox(height: TwoGoSpacing.lg),
          Row(
            children: [
              Expanded(
                child: TwoGoButton(
                  text: 'Voltar',
                  variant: TwoGoButtonVariant.secondary,
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ),
              const SizedBox(width: TwoGoSpacing.sm),
              Expanded(
                child: TwoGoButton(
                  text: 'Criar meu roteiro',
                  variant: TwoGoButtonVariant.primary,
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ),
            ],
          ),
          const SizedBox(height: TwoGoSpacing.sm),
        ],
      ),
    );
  }
}
