import 'package:flutter/material.dart';

/// Colors + spacing sampled from course Form PDFs (Onde / Age / Revisao).
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

  /// Revisao grey cards — design ~12px (sim previously used 16).
  static const double cardRadius = 12;

  /// Destino thumb corner.
  static const double thumbRadius = 8;

  /// Destino square photo size (Colosseum-style thumb).
  static const double destinoThumbSize = 56;

  /// Horizontal page gutter for step body.
  static const double pageGutter = 16;

  /// Gap between section label and its card.
  static const double labelToCardGap = 8;

  /// Vertical gap between Revisao sections.
  static const double sectionGap = 16;

  /// Gutter between Viajantes | Estilo equal cards.
  static const double cardGutter = 12;

  /// Inner padding of summary cards.
  static const double cardPadding = 16;

  /// Vertical gap between Principais interesses rows.
  static const double interestRowGap = 12;
}
