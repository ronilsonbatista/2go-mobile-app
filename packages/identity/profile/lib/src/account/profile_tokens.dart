import 'package:flutter/material.dart';

/// Spacing / colors measured from Perfil design PDFs at 390pt logical width.
///
/// Gutters sampled ≈ 22.6–23.4pt → fixed [pageGutter] 24 (same as FormCourse).
abstract final class ProfileTokens {
  static const double pageGutter = 24;
  static const double avatarDiameter = 112;
  static const double cameraBadgeSize = 36;
  static const double menuRadius = 18;
  static const double menuItemHeight = 56;
  static const double headerToAvatarGap = 40;
  static const double avatarToMenuGap = 40;
  static const double cardRadius = 14;
  static const double cardGap = 12;
  static const double fieldGap = 16;
  static const double cropRadius = 20;
  static const double backCircleSize = 40;

  /// Menu group fill (design ≈ #F7F6F2).
  static const Color menuSurface = Color(0xFFF7F6F2);

  /// Soft input fill on Dados pessoais.
  static const Color fieldFill = Color(0xFFF4F2EF);

  /// Destructive / highlight on delete confirm last-4.
  static const Color destructiveSoft = Color(0xFFFFE8E4);
  static const Color destructiveInk = Color(0xFFE24B3B);
  static const Color accentOrange = Color(0xFFE86A3A);

  /// Action-sheet system blue (iOS-style select sheet).
  static const Color actionBlue = Color(0xFF007AFF);

  static const Color sheetBarrier = Color(0x99000000);
}
