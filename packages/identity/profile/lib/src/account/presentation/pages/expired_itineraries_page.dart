import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

import '../../domain/expired_itinerary.dart';
import '../../profile_tokens.dart';
import '../widgets/profile_back_button.dart';

/// Roteiros expirados — design layout. No Core list endpoint yet.
class ExpiredItinerariesPage extends StatelessWidget {
  const ExpiredItinerariesPage({
    super.key,
    this.onBack,
    this.items = ExpiredItinerary.designDemos,
  });

  final VoidCallback? onBack;
  final List<ExpiredItinerary> items;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TwoGoColors.backgroundPrimary,
      appBar: profileAppBar(title: 'Roteiros expirados', onBack: onBack),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            ProfileTokens.pageGutter,
            TwoGoSpacing.md,
            ProfileTokens.pageGutter,
            TwoGoSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vai viajar novamente para esses destinos?',
                style: TwoGoTypography.headlineSmall.copyWith(
                  color: TwoGoColors.contentPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: TwoGoSpacing.xs),
              Text(
                'Aproveite a promoção e reative o roteiro com uma nova data.',
                style: TwoGoTypography.bodyMedium.copyWith(
                  color: TwoGoColors.contentSecondary,
                ),
              ),
              const SizedBox(height: TwoGoSpacing.lg),
              LayoutBuilder(
                builder: (context, constraints) {
                  const gap = ProfileTokens.cardGap;
                  final cardWidth = (constraints.maxWidth - gap) / 2;
                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: [
                      for (final item in items)
                        SizedBox(
                          width: cardWidth,
                          child: _ExpiredCard(item: item),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: TwoGoSpacing.xxl),
              Text(
                'Sobre desconto:',
                style: TwoGoTypography.titleMedium.copyWith(
                  color: ProfileTokens.accentOrange,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: TwoGoSpacing.xs),
              Text(
                'Desconto é valido apenas para novas datas. Outras alterações '
                'criarão um novo roteiro, retornando ao valor original.',
                style: TwoGoTypography.bodyMedium.copyWith(
                  color: TwoGoColors.contentSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpiredCard extends StatelessWidget {
  const _ExpiredCard({required this.item});

  final ExpiredItinerary item;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.92,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ProfileTokens.cardRadius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(
              color: TwoGoColors.neutral700,
              child: item.imageUrl != null
                  ? Image.network(
                      item.imageUrl!,
                      fit: BoxFit.cover,
                      color: Colors.grey,
                      colorBlendMode: BlendMode.saturation,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    )
                  : CustomPaint(painter: _PlaceholderCityPainter()),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54],
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: TwoGoColors.neutral0,
                  borderRadius: BorderRadius.circular(TwoGoRadius.full),
                ),
                child: Text(
                  item.discountLabel,
                  style: TwoGoTypography.labelSmall.copyWith(
                    color: TwoGoColors.brandLime,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 12,
              bottom: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.destination,
                    style: TwoGoTypography.titleMedium.copyWith(
                      color: TwoGoColors.neutral0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    item.daysLabel,
                    style: TwoGoTypography.bodySmall.copyWith(
                      color: TwoGoColors.neutral0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderCityPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = TwoGoColors.neutral600;
    canvas.drawRect(Offset.zero & size, paint);
    final skyline = Paint()..color = TwoGoColors.neutral500;
    final h = size.height;
    final w = size.width;
    canvas.drawRect(Rect.fromLTWH(0, h * 0.45, w * 0.2, h * 0.55), skyline);
    canvas.drawRect(Rect.fromLTWH(w * 0.22, h * 0.3, w * 0.18, h * 0.7), skyline);
    canvas.drawRect(Rect.fromLTWH(w * 0.45, h * 0.4, w * 0.25, h * 0.6), skyline);
    canvas.drawRect(Rect.fromLTWH(w * 0.75, h * 0.35, w * 0.25, h * 0.65), skyline);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
