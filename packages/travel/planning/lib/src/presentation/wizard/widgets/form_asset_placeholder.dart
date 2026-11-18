import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

import '../form_course_tokens.dart';

/// Visible stand-in until Ronilson supplies course icon assets.
class FormAssetPlaceholder extends StatelessWidget {
  const FormAssetPlaceholder({
    required this.assetName,
    this.size = 24,
    this.fallbackIcon,
    this.fallbackColor,
    super.key,
  });

  final String assetName;
  final double size;
  final IconData? fallbackIcon;
  final Color? fallbackColor;

  @override
  Widget build(BuildContext context) {
    if (fallbackIcon != null) {
      return Tooltip(
        message: 'ASSET_REQUIRED: $assetName',
        child: Icon(
          fallbackIcon,
          size: size,
          color: fallbackColor ?? FormCourseTokens.ink,
        ),
      );
    }

    return Tooltip(
      message: 'ASSET_REQUIRED: $assetName',
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: FormCourseTokens.summaryCard,
          borderRadius: BorderRadius.circular(TwoGoRadius.small),
          border: Border.all(color: FormCourseTokens.label),
        ),
        child: Text(
          '?',
          style: TwoGoTypography.labelSmall.copyWith(
            color: FormCourseTokens.ink,
            fontSize: size * 0.45,
          ),
        ),
      ),
    );
  }
}
