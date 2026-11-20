import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

import '../../domain/account_profile.dart';
import '../../profile_tokens.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.profile,
    this.onCameraTap,
    this.diameter = ProfileTokens.avatarDiameter,
    this.showCameraBadge = true,
  });

  final AccountProfile profile;
  final VoidCallback? onCameraTap;
  final double diameter;
  final bool showCameraBadge;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: diameter + 8,
      height: diameter + 8,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 4,
            top: 4,
            child: Container(
              width: diameter,
              height: diameter,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: TwoGoColors.neutral900,
                border: Border.all(color: TwoGoColors.neutral200, width: 1),
                image: profile.hasPhoto
                    ? DecorationImage(
                        image: NetworkImage(profile.photoUrl!),
                        fit: BoxFit.cover,
                        onError: (_, __) {},
                      )
                    : null,
              ),
              alignment: Alignment.center,
              child: profile.hasPhoto
                  ? null
                  : Text(
                      profile.initials,
                      style: TwoGoTypography.headlineMedium.copyWith(
                        color: TwoGoColors.neutral0,
                        fontWeight: FontWeight.w700,
                        fontSize: diameter * 0.32,
                      ),
                    ),
            ),
          ),
          if (showCameraBadge && onCameraTap != null)
            Positioned(
              right: 0,
              bottom: 0,
              child: Material(
                color: TwoGoColors.neutral0,
                shape: const CircleBorder(),
                elevation: 1,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onCameraTap,
                  child: Container(
                    width: ProfileTokens.cameraBadgeSize,
                    height: ProfileTokens.cameraBadgeSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: TwoGoColors.neutral200),
                    ),
                    child: const Icon(
                      Icons.photo_camera_outlined,
                      size: 18,
                      color: TwoGoColors.contentPrimary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
