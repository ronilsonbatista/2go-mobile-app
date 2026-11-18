import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

import '../form_course_tokens.dart';
import 'form_asset_placeholder.dart';

/// Course chrome icons shipped in `twogo_planning` assets (low-res interim).
abstract final class FormCourseIconAssets {
  static const package = 'twogo_planning';
  static const progressPlane = 'assets/icons/progress-plane-48.png';
  static const estiloDollar = 'assets/icons/estilo-dollar-3x.png';
}

class FormProgressPlaneIcon extends StatelessWidget {
  const FormProgressPlaneIcon({this.size = 22, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      FormCourseIconAssets.progressPlane,
      package: FormCourseIconAssets.package,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      errorBuilder: (_, __, ___) => const FormAssetPlaceholder(
        assetName: 'progress-plane',
        size: 22,
        fallbackIcon: TwoGoIcons.flight,
        fallbackColor: FormCourseTokens.black,
      ),
    );
  }
}

class FormEstiloDollarGlyph extends StatelessWidget {
  const FormEstiloDollarGlyph({
    required this.count,
    this.height = 22,
    super.key,
  });

  final int count;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < count; i++)
          Padding(
            padding: EdgeInsets.only(right: i == count - 1 ? 0 : 1),
            child: Image.asset(
              FormCourseIconAssets.estiloDollar,
              package: FormCourseIconAssets.package,
              height: height,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.none,
              errorBuilder: (_, __, ___) => Text(
                '\$',
                style: TwoGoTypography.titleLarge.copyWith(
                  color: FormCourseTokens.styleDollar,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
