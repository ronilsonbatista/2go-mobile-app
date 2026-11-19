import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

import '../../../domain/place_details_view_data.dart';
import '../place_details_tokens.dart';

/// "Ajustar duração" row with ± circles and H:MM value (PDF Modal / Detalhes-2).
class PlaceDurationStepper extends StatelessWidget {
  final int minutes;
  final int? recommendedMinutes;
  final ValueChanged<int>? onChanged;
  final int stepMinutes;
  final int minMinutes;
  final int maxMinutes;

  const PlaceDurationStepper({
    super.key,
    required this.minutes,
    this.recommendedMinutes,
    this.onChanged,
    this.stepMinutes = 10,
    this.minMinutes = 10,
    this.maxMinutes = 8 * 60,
  });

  @override
  Widget build(BuildContext context) {
    final recommended = recommendedMinutes ?? minutes;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: PlaceDetailsTokens.chipSurface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Ajustar duração',
                  style: TwoGoTypography.bodyMedium.copyWith(
                    color: PlaceDetailsTokens.muted,
                  ),
                ),
              ),
              _CircleBtn(
                icon: Icons.remove,
                enabled: minutes - stepMinutes >= minMinutes,
                onTap: onChanged == null
                    ? null
                    : () => onChanged!(
                        (minutes - stepMinutes).clamp(minMinutes, maxMinutes),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  formatDurationHm(minutes),
                  style: TwoGoTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: PlaceDetailsTokens.ink,
                  ),
                ),
              ),
              _CircleBtn(
                icon: Icons.add,
                enabled: minutes + stepMinutes <= maxMinutes,
                onTap: onChanged == null
                    ? null
                    : () => onChanged!(
                        (minutes + stepMinutes).clamp(minMinutes, maxMinutes),
                      ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.timer_outlined,
              size: 16,
              color: PlaceDetailsTokens.muted,
            ),
            const SizedBox(width: 6),
            Text.rich(
              TextSpan(
                style: TwoGoTypography.bodySmall.copyWith(
                  color: PlaceDetailsTokens.muted,
                ),
                children: [
                  const TextSpan(text: 'Duração recomendada '),
                  TextSpan(
                    text: '${formatDurationHm(recommended)} minutos',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback? onTap;

  const _CircleBtn({
    required this.icon,
    required this.enabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: enabled ? 1 : 0,
      shadowColor: Colors.black26,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: enabled ? onTap : null,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(
            icon,
            size: 18,
            color: enabled
                ? PlaceDetailsTokens.ink
                : PlaceDetailsTokens.muted,
          ),
        ),
      ),
    );
  }
}
