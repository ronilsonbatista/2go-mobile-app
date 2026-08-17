import 'package:flutter/material.dart';

/// Design System Radius Tokens for 2GO Mobile.
///
/// Defines border radius standards for inputs, buttons, cards, and bottom sheets.
abstract class TwoGoRadius {
  static const double small = 4.0;
  static const double medium = 8.0;
  static const double large = 16.0;
  static const double full = 999.0;

  static const BorderRadius borderSmall = BorderRadius.all(
    Radius.circular(small),
  );
  static const BorderRadius borderMedium = BorderRadius.all(
    Radius.circular(medium),
  );
  static const BorderRadius borderLarge = BorderRadius.all(
    Radius.circular(large),
  );
  static const BorderRadius borderFull = BorderRadius.all(
    Radius.circular(full),
  );

  static const BorderRadius sheetTop = BorderRadius.only(
    topLeft: Radius.circular(large),
    topRight: Radius.circular(large),
  );
}
