import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

import '../../domain/models/home_destination.dart';
import 'home_destination_image.dart';

/// Full-bleed hero PageView with destination caption (course Home frames).
class HomeHeroCarousel extends StatefulWidget {
  const HomeHeroCarousel({
    required this.destinations,
    required this.index,
    required this.onIndexChanged,
    this.onDestinationTap,
    super.key,
  });

  final List<HomeDestination> destinations;
  final int index;
  final ValueChanged<int> onIndexChanged;

  /// Opens create-itinerary / Onde with the visible hero destination.
  final ValueChanged<HomeDestination>? onDestinationTap;

  @override
  State<HomeHeroCarousel> createState() => _HomeHeroCarouselState();
}

class _HomeHeroCarouselState extends State<HomeHeroCarousel> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: widget.index);
  }

  @override
  void didUpdateWidget(covariant HomeHeroCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index &&
        _controller.hasClients &&
        (_controller.page?.round() ?? widget.index) != widget.index) {
      _controller.animateToPage(
        widget.index,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.destinations.isEmpty) {
      return const ColoredBox(color: TwoGoColors.surfaceSecondary);
    }

    final current = widget.destinations[
      widget.index.clamp(0, widget.destinations.length - 1)
    ];

    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: _controller,
          itemCount: widget.destinations.length,
          onPageChanged: widget.onIndexChanged,
          itemBuilder: (context, index) {
            final destination = widget.destinations[index];
            return Semantics(
              button: widget.onDestinationTap != null,
              label: destination.caption,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.onDestinationTap == null
                    ? null
                    : () => widget.onDestinationTap!(destination),
                child: HomeDestinationImage(
                  imageUrl: destination.resolvedHeroUrl,
                  assetPath: destination.heroAssetPath,
                ),
              ),
            );
          },
        ),
        // Soft bottom fade so white sheet transition reads cleanly.
        // Ignore pointer so taps reach the destination GestureDetector below.
        const Align(
          alignment: Alignment.bottomCenter,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x00000000),
                    Color(0x33000000),
                  ],
                ),
              ),
              child: SizedBox(height: 96, width: double.infinity),
            ),
          ),
        ),
        Positioned(
          left: TwoGoSpacing.lg,
          bottom: TwoGoSpacing.xl + 8,
          right: TwoGoSpacing.xxl,
          child: IgnorePointer(
            child: Text(
              current.caption,
              style: TwoGoTypography.titleMedium.copyWith(
                color: TwoGoColors.neutral0,
                fontWeight: FontWeight.w500,
                shadows: const [
                  Shadow(
                    color: Color(0x66000000),
                    blurRadius: 8,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
