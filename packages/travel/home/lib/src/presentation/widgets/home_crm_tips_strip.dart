import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

import '../../domain/models/home_tip.dart';

/// Horizontal "Dicas para você" cards (≤3 from backend).
class HomeCrmTipsStrip extends StatelessWidget {
  const HomeCrmTipsStrip({
    super.key,
    required this.tips,
  });

  final List<HomeTip> tips;

  @override
  Widget build(BuildContext context) {
    if (tips.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: TwoGoSpacing.lg),
          child: Text(
            'Dicas para você 📣',
            style: TwoGoTypography.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: TwoGoSpacing.md),
        SizedBox(
          height: 168,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: TwoGoSpacing.lg),
            // Tips already capped ≤3 per destination in HomeTipsParser / Core.
            itemCount: tips.length,
            separatorBuilder: (_, __) => const SizedBox(width: TwoGoSpacing.sm),
            itemBuilder: (context, index) {
              final tip = tips[index];
              return _TipCard(tip: tip);
            },
          ),
        ),
      ],
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({required this.tip});

  final HomeTip tip;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(TwoGoSpacing.md),
      decoration: BoxDecoration(
        color: TwoGoColors.neutral100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tip.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TwoGoTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: TwoGoColors.contentPrimary,
            ),
          ),
          const SizedBox(height: TwoGoSpacing.sm),
          Expanded(
            child: Text(
              tip.body,
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
              style: TwoGoTypography.bodyMedium.copyWith(
                color: TwoGoColors.contentSecondary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
