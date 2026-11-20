import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

import '../../domain/trip_share_models.dart';

/// Member details sheet: pending vs accepted, resend + exclude.
class TripShareMemberSheet extends StatelessWidget {
  const TripShareMemberSheet({
    super.key,
    required this.participant,
    required this.onResend,
    required this.onExclude,
    this.resending = false,
  });

  final TripParticipant participant;
  final Future<void> Function() onResend;
  final Future<void> Function() onExclude;
  final bool resending;

  static Future<void> show(
    BuildContext context, {
    required TripParticipant participant,
    required Future<void> Function() onResend,
    required Future<void> Function() onExclude,
  }) {
    return TwoGoBottomSheet.show<void>(
      context,
      title: 'Detalhes',
      child: TripShareMemberSheet(
        participant: participant,
        onResend: onResend,
        onExclude: onExclude,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(TwoGoSpacing.md),
          decoration: BoxDecoration(
            color: TwoGoColors.surfacePrimary,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: TwoGoColors.borderDefault),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: participant.accepted
                    ? TwoGoColors.neutral900
                    : TwoGoColors.neutral200,
                child: Text(
                  participant.initials,
                  style: TwoGoTypography.labelLarge.copyWith(
                    color: participant.accepted
                        ? TwoGoColors.contentInverse
                        : TwoGoColors.contentSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: TwoGoSpacing.md),
              Expanded(
                child: Text(
                  participant.label,
                  style: TwoGoTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!participant.accepted) ...[
          const SizedBox(height: TwoGoSpacing.md),
          Text(
            'Essa pessoa ainda não aceitou o convite',
            textAlign: TextAlign.center,
            style: TwoGoTypography.bodyMedium.copyWith(
              color: TwoGoColors.contentSecondary,
            ),
          ),
        ],
        const SizedBox(height: TwoGoSpacing.lg),
        TwoGoButton(
          text: 'Reenviar roteiro',
          variant: TwoGoButtonVariant.secondary,
          loading: resending,
          onPressed: () async {
            await onResend();
            if (context.mounted) Navigator.of(context).pop();
          },
        ),
        const SizedBox(height: TwoGoSpacing.md),
        TextButton(
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Excluir viajante'),
                content: Text(
                  'Remover ${participant.label} deste roteiro?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    style: TextButton.styleFrom(
                      foregroundColor: TwoGoColors.error,
                    ),
                    child: const Text('Excluir'),
                  ),
                ],
              ),
            );
            if (confirmed != true) return;
            await onExclude();
            if (context.mounted) Navigator.of(context).pop();
          },
          child: Text(
            'Excluir Viajante',
            style: TwoGoTypography.labelLarge.copyWith(
              color: TwoGoColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
