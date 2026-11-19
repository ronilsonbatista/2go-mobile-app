import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

import '../../domain/models/home_profile.dart';
import 'home_asset_image.dart';

/// Top-right profile control matching course Home-9 / Home-10 / Home-11.
class HomeProfileChip extends StatelessWidget {
  const HomeProfileChip({
    required this.profile,
    required this.onTap,
    super.key,
  });

  final HomeProfile profile;
  final VoidCallback onTap;

  static const double diameter = 40;

  @override
  Widget build(BuildContext context) {
    final showChevron = profile.isAuthenticated;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.all(TwoGoSpacing.xs),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Avatar(profile: profile),
              if (showChevron) ...[
                const SizedBox(width: TwoGoSpacing.xxs),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 22,
                  color: TwoGoColors.neutral900,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.profile});

  final HomeProfile profile;

  @override
  Widget build(BuildContext context) {
    if (!profile.isAuthenticated) {
      // Home-9: black circle + white silhouette (no customer photo).
      return Container(
        width: HomeProfileChip.diameter,
        height: HomeProfileChip.diameter,
        decoration: const BoxDecoration(
          color: TwoGoColors.neutral900,
          shape: BoxShape.circle,
        ),
        // Guest silhouette — Material person (needs uses-material-design).
        child: const Icon(
          Icons.person,
          size: 22,
          color: TwoGoColors.neutral0,
        ),
      );
    }

    if (profile.hasPhoto) {
      // Home-10: customer photo + light border.
      final ImageProvider image;
      if (profile.photoUrl != null && profile.photoUrl!.isNotEmpty) {
        image = NetworkImage(profile.photoUrl!);
      } else {
        image = HomeAssetImage.provider(profile.photoAssetPath!);
      }

      return Container(
        width: HomeProfileChip.diameter,
        height: HomeProfileChip.diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: TwoGoColors.neutral0, width: 2),
          image: DecorationImage(image: image, fit: BoxFit.cover),
        ),
      );
    }

    // Home-11: initials on black circle.
    final initials = (profile.initials ?? '2G').toUpperCase();
    return Container(
      width: HomeProfileChip.diameter,
      height: HomeProfileChip.diameter,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: TwoGoColors.neutral900,
        shape: BoxShape.circle,
      ),
      child: Text(
        initials.length > 2 ? initials.substring(0, 2) : initials,
        style: TwoGoTypography.titleMedium.copyWith(
          color: TwoGoColors.neutral0,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
