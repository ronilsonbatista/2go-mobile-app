import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

import '../../domain/trip_share_models.dart';

/// Home first-open guest welcome (`Home_-_convidado`).
///
/// Aceitar → mark-seen (membership kept). Recusar / X → dismiss without seen
/// so it can show again on next Home open.
class TripWelcomeSheet extends StatelessWidget {
  const TripWelcomeSheet({
    super.key,
    required this.item,
    required this.onAccept,
    this.onDecline,
    this.accepting = false,
  });

  final TripWelcomeItem item;
  final Future<void> Function() onAccept;
  final VoidCallback? onDecline;
  final bool accepting;

  static const _monthsPt = <String>[
    'janeiro',
    'fevereiro',
    'março',
    'abril',
    'maio',
    'junho',
    'julho',
    'agosto',
    'setembro',
    'outubro',
    'novembro',
    'dezembro',
  ];

  static Future<bool?> show(
    BuildContext context, {
    required TripWelcomeItem item,
    required Future<void> Function() onAccept,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TripWelcomeSheet(
        item: item,
        onAccept: () async {
          await onAccept();
          if (ctx.mounted) Navigator.of(ctx).pop(true);
        },
        onDecline: () => Navigator.of(ctx).pop(false),
      ),
    );
  }

  static String _formatPt(DateTime date) {
    return '${date.day} de ${_monthsPt[date.month - 1]}';
  }

  String _dateLine(DateTime? start, DateTime? end) {
    if (start == null) return '';
    final startLabel = _formatPt(start);
    if (end == null) return startLabel;
    return '$startLabel\naté ${_formatPt(end)}';
  }

  @override
  Widget build(BuildContext context) {
    final trip = item.trip;
    final destination = trip.destination.isNotEmpty
        ? trip.destination
        : (trip.title.isNotEmpty ? trip.title : 'Viagem');
    final inviter = trip.inviterName?.trim().isNotEmpty == true
        ? trip.inviterName!.trim()
        : 'um amigo';
    final dates = _dateLine(trip.startDate, trip.endDate);
    final cover = trip.coverImage?.trim();

    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: TwoGoColors.surfacePrimary,
          borderRadius: TwoGoRadius.sheetTop,
        ),
        padding: const EdgeInsets.fromLTRB(
          TwoGoSpacing.lg,
          TwoGoSpacing.md,
          TwoGoSpacing.lg,
          TwoGoSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Convite',
                    style: TwoGoTypography.headlineSmall.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Material(
                  color: TwoGoColors.neutral100,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onDecline ?? () => Navigator.of(context).pop(false),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.close, size: 18),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: TwoGoSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (cover != null && cover.isNotEmpty)
                      Image.network(
                        cover,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const ColoredBox(
                          color: TwoGoColors.neutral300,
                        ),
                      )
                    else
                      const ColoredBox(color: TwoGoColors.neutral300),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x00000000), Color(0x99000000)],
                        ),
                      ),
                    ),
                    Positioned(
                      left: TwoGoSpacing.md,
                      bottom: TwoGoSpacing.md,
                      right: TwoGoSpacing.md,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              destination,
                              style: TwoGoTypography.headlineMedium.copyWith(
                                color: TwoGoColors.contentInverse,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (dates.isNotEmpty)
                            Text(
                              dates,
                              textAlign: TextAlign.right,
                              style: TwoGoTypography.bodySmall.copyWith(
                                color: TwoGoColors.contentInverse,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: TwoGoSpacing.lg),
            Text.rich(
              TextSpan(
                style: TwoGoTypography.bodyLarge.copyWith(
                  color: TwoGoColors.contentPrimary,
                  height: 1.4,
                ),
                children: [
                  const TextSpan(
                    text: 'Você recebeu um convite para se juntar a ',
                  ),
                  TextSpan(
                    text: inviter,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const TextSpan(text: ' nessa viagem.'),
                ],
              ),
            ),
            const SizedBox(height: TwoGoSpacing.lg),
            TwoGoButton(
              text: 'Aceitar',
              loading: accepting,
              onPressed: accepting ? null : onAccept,
            ),
            const SizedBox(height: TwoGoSpacing.sm),
            TextButton(
              onPressed: onDecline ?? () => Navigator.of(context).pop(false),
              child: Text(
                'Recusar',
                style: TwoGoTypography.labelLarge.copyWith(
                  color: TwoGoColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
