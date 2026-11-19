import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

import '../form_course_tokens.dart';

/// Course chrome icons shipped in `twogo_planning` assets.
abstract final class FormCourseIconAssets {
  static const package = 'twogo_planning';
  static const estiloDollar = 'assets/icons/estilo-dollar-3x.png';
}

/// Clean vector progress plane (interim until Ronilson supplies final asset).
///
/// Prefer this over the low-res screenshot PNG — solid black silhouette,
/// nose right, no drop shadow.
class FormProgressPlaneIcon extends StatelessWidget {
  const FormProgressPlaneIcon({this.size = 22, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: const _ProgressPlanePainter(),
        size: Size.square(size),
      ),
    );
  }
}

class _ProgressPlanePainter extends CustomPainter {
  const _ProgressPlanePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = FormCourseTokens.black
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final w = size.width;
    final h = size.height;
    // Top-down jet, nose pointing right — normalized 0..1 then scaled.
    final path = Path()
      // Nose
      ..moveTo(0.92 * w, 0.50 * h)
      // Upper fuselage → wing root
      ..lineTo(0.62 * w, 0.42 * h)
      // Upper wing tip
      ..lineTo(0.38 * w, 0.12 * h)
      ..lineTo(0.30 * w, 0.12 * h)
      ..lineTo(0.42 * w, 0.40 * h)
      // Tail upper
      ..lineTo(0.14 * w, 0.36 * h)
      ..lineTo(0.08 * w, 0.28 * h)
      ..lineTo(0.10 * w, 0.42 * h)
      ..lineTo(0.18 * w, 0.48 * h)
      // Tail lower (mirror)
      ..lineTo(0.10 * w, 0.58 * h)
      ..lineTo(0.08 * w, 0.72 * h)
      ..lineTo(0.14 * w, 0.64 * h)
      ..lineTo(0.42 * w, 0.60 * h)
      // Lower wing tip
      ..lineTo(0.30 * w, 0.88 * h)
      ..lineTo(0.38 * w, 0.88 * h)
      ..lineTo(0.62 * w, 0.58 * h)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
