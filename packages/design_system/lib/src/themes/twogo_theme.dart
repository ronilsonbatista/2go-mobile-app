import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// Central Theme manager for 2GO Mobile Design System.
abstract class TwoGoTheme {
  /// Primary Light Theme based on official product reference design.
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: TwoGoColors.brandLime,
      scaffoldBackgroundColor: TwoGoColors.backgroundPrimary,
      fontFamily: TwoGoTypography.fontFamily,
      colorScheme: const ColorScheme.light(
        primary: TwoGoColors.brandLime,
        secondary: TwoGoColors.neutral900,
        surface: TwoGoColors.surfacePrimary,
        error: TwoGoColors.error,
        onPrimary: TwoGoColors.neutral900,
        onSecondary: TwoGoColors.neutral0,
        onSurface: TwoGoColors.contentPrimary,
        onError: TwoGoColors.neutral0,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: TwoGoColors.surfacePrimary,
        foregroundColor: TwoGoColors.contentPrimary,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: TwoGoColors.borderDefault,
        thickness: 1,
        space: TwoGoSpacing.md,
      ),
      cardTheme: const CardThemeData(
        color: TwoGoColors.surfacePrimary,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: TwoGoColors.borderDefault),
          borderRadius: TwoGoRadius.borderLarge,
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: TwoGoColors.toastBackground,
        contentTextStyle: TextStyle(
          color: TwoGoColors.contentInverse,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(borderRadius: TwoGoRadius.borderMedium),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Dark Theme contract prepared for future official dark design references.
  static ThemeData get dark {
    // Structural dark fallback until dark design specs are provided
    return light.copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: TwoGoColors.neutral900,
      colorScheme: const ColorScheme.dark(
        primary: TwoGoColors.brandLime,
        surface: TwoGoColors.neutral800,
        onSurface: TwoGoColors.neutral0,
      ),
    );
  }
}
