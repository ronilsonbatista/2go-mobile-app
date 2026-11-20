import 'dart:async';

import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

/// Live countdown until trip start (`summary.startDate`).
class PlanningPreviewCountdown extends StatefulWidget {
  const PlanningPreviewCountdown({
    super.key,
    required this.startDate,
    this.now,
  });

  /// ISO date or datetime from Core preview summary.
  final String? startDate;

  /// Override clock for tests.
  final DateTime Function()? now;

  @override
  State<PlanningPreviewCountdown> createState() =>
      _PlanningPreviewCountdownState();
}

class _PlanningPreviewCountdownState extends State<PlanningPreviewCountdown> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _tick();
    // Fixed clock (tests / screenshots) — no periodic timer.
    if (widget.now == null) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    }
  }

  @override
  void didUpdateWidget(covariant PlanningPreviewCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.startDate != widget.startDate) {
      _tick();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  DateTime get _now => widget.now?.call() ?? DateTime.now();

  void _tick() {
    final target = _parseStart(widget.startDate);
    final next = target == null
        ? Duration.zero
        : target.difference(_now);
    final clamped = next.isNegative ? Duration.zero : next;
    if (clamped != _remaining) {
      setState(() => _remaining = clamped);
    }
  }

  static DateTime? _parseStart(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final parsed = DateTime.tryParse(raw.trim());
    if (parsed == null) return null;
    // Date-only → start of local day.
    if (raw.trim().length <= 10) {
      return DateTime(parsed.year, parsed.month, parsed.day);
    }
    return parsed.toLocal();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.startDate == null || widget.startDate!.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final days = _remaining.inDays;
    final hours = _remaining.inHours.remainder(24);
    final minutes = _remaining.inMinutes.remainder(60);

    // Digits must dominate / fill the white card (Ronilson 2026-11-20).
    // Tiles 28×36 with xs vertical pad ≈ digit stack ~70% of card height.
    // No FittedBox (it was shrinking tiles below the intended size).
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: TwoGoSpacing.md,
        vertical: TwoGoSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: TwoGoColors.neutral100,
        borderRadius: BorderRadius.circular(TwoGoRadius.medium),
      ),
      child: Row(
        children: [
          Flexible(
            child: Text(
              'Faltam apenas',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TwoGoTypography.bodyMedium.copyWith(
                color: TwoGoColors.contentPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: TwoGoSpacing.xs),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DigitPair(value: days, label: 'dias'),
              const SizedBox(width: 6),
              _DigitPair(value: hours, label: 'horas'),
              const SizedBox(width: 6),
              _DigitPair(value: minutes, label: 'minutos'),
            ],
          ),
        ],
      ),
    );
  }
}

class _DigitPair extends StatelessWidget {
  const _DigitPair({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final padded = value.clamp(0, 99).toString().padLeft(2, '0');
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DigitBox(padded[0]),
            const SizedBox(width: 2),
            _DigitBox(padded[1]),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TwoGoTypography.labelSmall.copyWith(
            color: TwoGoColors.contentSecondary,
            fontSize: 9,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}

class _DigitBox extends StatelessWidget {
  const _DigitBox(this.digit);

  final String digit;

  /// Lime tile sized to fill the countdown card (~28×36).
  static const double sizeW = 28;
  static const double sizeH = 36;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: sizeW,
      height: sizeH,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: TwoGoColors.brandLime,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        digit,
        style: TwoGoTypography.labelMedium.copyWith(
          fontWeight: FontWeight.w800,
          fontSize: 18,
          color: TwoGoColors.neutral900,
          height: 1,
        ),
      ),
    );
  }
}
