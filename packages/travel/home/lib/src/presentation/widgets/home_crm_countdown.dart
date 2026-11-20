import 'dart:async';

import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

/// White digit-tile countdown overlay for "Próxima viagem" (Home-1…7).
///
/// Design uses white rounded squares (not lime preview tiles).
class HomeCrmCountdown extends StatefulWidget {
  const HomeCrmCountdown({
    super.key,
    required this.target,
    this.now,
  });

  final DateTime? target;
  final DateTime Function()? now;

  @override
  State<HomeCrmCountdown> createState() => _HomeCrmCountdownState();
}

class _HomeCrmCountdownState extends State<HomeCrmCountdown> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _tick();
    if (widget.now == null) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    }
  }

  @override
  void didUpdateWidget(covariant HomeCrmCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.target != widget.target) _tick();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  DateTime get _now => widget.now?.call() ?? DateTime.now();

  void _tick() {
    final target = widget.target;
    final next = target == null ? Duration.zero : target.difference(_now);
    final clamped = next.isNegative ? Duration.zero : next;
    if (clamped != _remaining) {
      setState(() => _remaining = clamped);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.target == null) return const SizedBox.shrink();

    final days = _remaining.inDays;
    final hours = _remaining.inHours.remainder(24);
    final minutes = _remaining.inMinutes.remainder(60);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _DigitPair(value: days, label: 'dias'),
        const SizedBox(width: 6),
        _DigitPair(value: hours, label: 'horas'),
        const SizedBox(width: 6),
        _DigitPair(value: minutes, label: 'minutos'),
      ],
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
        const SizedBox(height: 2),
        Text(
          label,
          style: TwoGoTypography.labelSmall.copyWith(
            color: TwoGoColors.neutral0,
            fontSize: 9,
            height: 1.1,
            fontWeight: FontWeight.w500,
            shadows: const [
              Shadow(blurRadius: 4, color: Color(0x66000000)),
            ],
          ),
        ),
      ],
    );
  }
}

class _DigitBox extends StatelessWidget {
  const _DigitBox(this.digit);

  final String digit;

  static const double size = 22;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: TwoGoColors.neutral0,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        digit,
        style: TwoGoTypography.labelMedium.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 13,
          color: TwoGoColors.neutral900,
          height: 1,
        ),
      ),
    );
  }
}
