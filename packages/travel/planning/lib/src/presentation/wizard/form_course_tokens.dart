import 'package:flutter/material.dart';

/// Colors sampled from course Form PDFs (Onde / Age / Interesses / Estilo).
///
/// Prefer these for course-aligned chrome; fall back to [TwoGoColors] elsewhere.
abstract final class FormCourseTokens {
  static const Color background = Color(0xFFF4F2EF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color summaryCard = Color(0xFFEBE9E6);
  static const Color lime = Color(0xFFBAD300);
  static const Color interestSelectedFill = Color(0xFFF8FBE3);
  static const Color disabledButton = Color(0xFFDEE0E0);
  static const Color disabledLabel = Color(0xFF848A89);
  static const Color label = Color(0xFF848A89);
  static const Color ink = Color(0xFF353838);
  static const Color black = Color(0xFF000000);
  static const Color styleDollar = Color(0xFF3A4088);
}
