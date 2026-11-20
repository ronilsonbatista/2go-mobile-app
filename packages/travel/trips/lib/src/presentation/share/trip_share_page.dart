import 'package:flutter/material.dart';
import 'package:twogo_core/twogo_core.dart';
import 'package:twogo_design_system/design_system.dart';

import '../../data/datasources/trip_share_api_client.dart';
import '../../domain/trip_share_models.dart';
import 'trip_share_invite_sheet.dart';
import 'trip_share_member_sheet.dart';

/// Owner share entry: members list + invite (Roma compartilhar PDFs).
class TripSharePage extends StatefulWidget {
  const TripSharePage({
    super.key,
    required this.tripId,
    required this.apiClient,
    this.destinationName = 'Viagem',
    this.coverImageUrl,
    this.startDate,
    this.endDate,
    this.maxTravelers,
    this.onBack,
  });

  final String tripId;
  final TripShareApiClient apiClient;
  final String destinationName;
  final String? coverImageUrl;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? maxTravelers;
  final VoidCallback? onBack;

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

  @override
  State<TripSharePage> createState() => _TripSharePageState();
}

class _TripSharePageState extends State<TripSharePage> {
  final Map<String, String> _localNames = {};
  List<TripParticipant> _participants = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await widget.apiClient.listParticipants(widget.tripId);
      if (!mounted) return;
      setState(() {
        _participants = list
            .map(
              (p) => _localNames.containsKey(p.email.toLowerCase())
                  ? p.copyWith(displayName: _localNames[p.email.toLowerCase()])
                  : p,
            )
            .toList(growable: false);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      final failure = e is AppFailure
          ? e
          : UnknownFailure(message: e.toString(), statusCode: 500);
      TwoGoErrorFeedback.present(context, failure);
      setState(() {
        _loading = false;
        _error = failure.message;
      });
    }
  }

  bool get _atCapacity {
    final max = widget.maxTravelers;
    if (max == null) return false;
    return _participants.length >= max;
  }

  String _datesLabel() {
    final start = widget.startDate;
    if (start == null) return '';
    final startLabel =
        '${start.day} de ${TripSharePage._monthsPt[start.month - 1]}';
    final end = widget.endDate;
    if (end == null) return startLabel;
    return '$startLabel\naté ${end.day} de ${TripSharePage._monthsPt[end.month - 1]}';
  }

  Future<void> _openInvite() async {
    final ok = await TripShareInviteSheet.show(
      context,
      onSubmit: ({required name, required email}) async {
        try {
          await widget.apiClient.inviteParticipant(
            widget.tripId,
            email: email,
          );
          _localNames[email.trim().toLowerCase()] = name.trim();
        } catch (e) {
          if (!mounted) rethrow;
          final failure = e is AppFailure
              ? e
              : UnknownFailure(message: e.toString(), statusCode: 500);
          TwoGoErrorFeedback.present(context, failure);
          rethrow;
        }
      },
    );
    if (ok == true && mounted) {
      TwoGoSnackbar.show(
        context,
        message: 'Roteiro enviado!',
        variant: TwoGoSnackbarVariant.success,
      );
      await _reload();
    }
  }

  Future<void> _openMember(TripParticipant participant) async {
    await TripShareMemberSheet.show(
      context,
      participant: participant,
      onResend: () async {
        // Core has no dedicated resend — toast matches design after invite.
        if (!mounted) return;
        TwoGoSnackbar.show(
          context,
          message: 'Roteiro enviado!',
          variant: TwoGoSnackbarVariant.success,
        );
      },
      onExclude: () async {
        try {
          await widget.apiClient.removeParticipant(
            widget.tripId,
            participant.id,
          );
          await _reload();
        } catch (e) {
          if (!mounted) return;
          final failure = e is AppFailure
              ? e
              : UnknownFailure(message: e.toString(), statusCode: 500);
          TwoGoErrorFeedback.present(context, failure);
          rethrow;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;
    final dates = _datesLabel();
    final cover = widget.coverImageUrl?.trim();

    return Scaffold(
      backgroundColor: TwoGoColors.backgroundSecondary,
      body: Column(
        children: [
          SizedBox(
            height: 220 + topPad,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (cover != null && cover.isNotEmpty)
                  Image.network(
                    cover,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const ColoredBox(
                      color: TwoGoColors.neutral800,
                    ),
                  )
                else
                  const ColoredBox(color: TwoGoColors.neutral800),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x66000000),
                        Color(0x00000000),
                        Color(0x99000000),
                      ],
                      stops: [0, 0.45, 1],
                    ),
                  ),
                ),
                Positioned(
                  top: topPad + TwoGoSpacing.xs,
                  left: TwoGoSpacing.sm,
                  child: Material(
                    color: TwoGoColors.neutral0.withValues(alpha: 0.92),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: widget.onBack ?? () => Navigator.of(context).maybePop(),
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(Icons.chevron_left_rounded, size: 22),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: TwoGoSpacing.md,
                  right: TwoGoSpacing.md,
                  bottom: TwoGoSpacing.md,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          widget.destinationName,
                          style: TwoGoTypography.headlineLarge.copyWith(
                            color: TwoGoColors.contentInverse,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (dates.isNotEmpty)
                        Text(
                          dates,
                          textAlign: TextAlign.right,
                          style: TwoGoTypography.bodyMedium.copyWith(
                            color: TwoGoColors.contentInverse,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                TwoGoSpacing.lg,
                TwoGoSpacing.lg,
                TwoGoSpacing.lg,
                TwoGoSpacing.xl,
              ),
              children: [
                Text.rich(
                  TextSpan(
                    style: TwoGoTypography.titleLarge.copyWith(
                      color: TwoGoColors.contentSecondary,
                      height: 1.35,
                    ),
                    children: [
                      TextSpan(
                        text: 'Compartilhe o roteiro',
                        style: TwoGoTypography.titleLarge.copyWith(
                          color: TwoGoColors.contentPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const TextSpan(text: ' com quem irá viajar com você'),
                    ],
                  ),
                ),
                const SizedBox(height: TwoGoSpacing.lg),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: TwoGoSpacing.xl),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_error != null && _participants.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: TwoGoSpacing.lg),
                    child: Column(
                      children: [
                        Text(
                          'Não foi possível carregar os viajantes.',
                          style: TwoGoTypography.bodyMedium.copyWith(
                            color: TwoGoColors.contentSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: TwoGoSpacing.md),
                        TwoGoButton(
                          text: 'Tentar de novo',
                          onPressed: _reload,
                        ),
                      ],
                    ),
                  )
                else ...[
                  for (final p in _participants) ...[
                    _ParticipantTile(
                      participant: p,
                      onTap: () => _openMember(p),
                      onDismissed: () async {
                        try {
                          await widget.apiClient.removeParticipant(
                            widget.tripId,
                            p.id,
                          );
                          await _reload();
                        } catch (e) {
                          if (!mounted) return;
                          final failure = e is AppFailure
                              ? e
                              : UnknownFailure(
                                  message: e.toString(),
                                  statusCode: 500,
                                );
                          TwoGoErrorFeedback.present(context, failure);
                          await _reload();
                        }
                      },
                    ),
                    const SizedBox(height: TwoGoSpacing.sm),
                  ],
                  if (!_atCapacity)
                    _AddTravelerTile(onTap: _openInvite)
                  else
                    Padding(
                      padding: const EdgeInsets.only(top: TwoGoSpacing.md),
                      child: Text(
                        'Você alcançou o número total de viajantes desse roteiro.',
                        textAlign: TextAlign.center,
                        style: TwoGoTypography.bodySmall.copyWith(
                          color: TwoGoColors.contentSecondary,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddTravelerTile extends StatelessWidget {
  const _AddTravelerTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TwoGoColors.surfacePrimary,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: TwoGoSpacing.md,
            vertical: TwoGoSpacing.md,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: TwoGoColors.borderDefault),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: TwoGoColors.brandLime,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: TwoGoColors.neutral900),
              ),
              const SizedBox(width: TwoGoSpacing.md),
              Text(
                'Adicionar viajantes',
                style: TwoGoTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ParticipantTile extends StatelessWidget {
  const _ParticipantTile({
    required this.participant,
    required this.onTap,
    required this.onDismissed,
  });

  final TripParticipant participant;
  final VoidCallback onTap;
  final Future<void> Function() onDismissed;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(participant.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Excluir viajante'),
            content: Text('Remover ${participant.label} deste roteiro?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: TextButton.styleFrom(foregroundColor: TwoGoColors.error),
                child: const Text('Excluir'),
              ),
            ],
          ),
        );
        if (ok == true) await onDismissed();
        return ok == true;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: TwoGoSpacing.lg),
        decoration: BoxDecoration(
          color: TwoGoColors.errorLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: TwoGoColors.error),
      ),
      child: Material(
        color: TwoGoColors.surfacePrimary,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: TwoGoSpacing.md,
              vertical: TwoGoSpacing.md,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: TwoGoColors.borderDefault),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: participant.accepted
                      ? TwoGoColors.neutral900
                      : TwoGoColors.neutral200,
                  child: Text(
                    participant.initials,
                    style: TwoGoTypography.labelMedium.copyWith(
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
                    style: TwoGoTypography.titleMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
