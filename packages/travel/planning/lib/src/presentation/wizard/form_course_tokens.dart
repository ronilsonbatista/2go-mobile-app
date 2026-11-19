import 'package:flutter/material.dart';

/// Colors + spacing sampled from course Form PDFs (Onde / Age / Revisao /
/// Interesses) at iPhone 16 logical width (393pt).
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

  /// Revisao / Destino grey+white cards — design ~12px.
  static const double cardRadius = 12;

  /// Interesses / Estilo selection rows — design ~8px.
  static const double rowCardRadius = 8;

  /// Destino thumb corner.
  static const double thumbRadius = 8;

  /// Destino square photo size (Colosseum-style thumb).
  static const double destinoThumbSize = 56;

  /// Horizontal page gutter (cards + Continuar). Design prints ≈ 23.4–24.4pt.
  /// Prior token 16 left content too tight vs Onde / Interesses / Revisao a050.
  static const double pageGutter = 24;

  /// Gap between section label and its card.
  static const double labelToCardGap = 8;

  /// Vertical gap between Revisao sections / Onde destination cards.
  static const double sectionGap = 12;

  /// Gutter between Viajantes | Estilo equal cards.
  static const double cardGutter = 12;

  /// Inner padding of summary cards.
  static const double cardPadding = 16;

  /// Vertical gap between Principais interesses / Interesses rows.
  static const double interestRowGap = 12;

  /// Back chevron circle — design ≈ 39pt.
  static const double backCircleSize = 40;

  /// Age +/− circles — design ≈ 31pt (was 40).
  static const double stepperCircleSize = 32;

  /// Gap between Age +/− circles and the count (edge-to-edge ≈ 52–55 design).
  static const double stepperValueGap = 12;

  /// Fixed width for the Age count so +/− stay balanced.
  static const double stepperValueWidth = 28;

  /// Divider height between Age traveler rows.
  /// With 48pt touch targets, 44 yields ~92pt circle-center pitch (design).
  static const double travelerRowDividerHeight = 44;
}
