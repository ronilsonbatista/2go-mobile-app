import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

import '../../domain/models/home_destination.dart';
import 'home_destination_image.dart';

/// Portrait destination card for "Destinos em alta".
class HomeDestinationCard extends StatelessWidget {
  const HomeDestinationCard({
    required this.destination,
    required this.onTap,
    this.width = 132,
    this.height = 196,
    super.key,
  });

  final HomeDestination destination;
  final VoidCallback onTap;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: destination.name,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: width,
          height: height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              fit: StackFit.expand,
              children: [
                HomeDestinationImage(
                  imageUrl: destination.resolvedCardUrl,
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x00000000),
                        Color(0x99000000),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: TwoGoSpacing.sm,
                  right: TwoGoSpacing.sm,
                  bottom: TwoGoSpacing.sm,
                  child: Text(
                    destination.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TwoGoTypography.titleMedium.copyWith(
                      color: TwoGoColors.neutral0,
                      fontWeight: FontWeight.w700,
                    ),
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
