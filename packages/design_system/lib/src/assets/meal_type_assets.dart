/// Standard café / almoço / jantar illustrations for timeline meal cards.
enum MealTypeAsset {
  cafe,
  almoco,
  jantar,
}

abstract final class MealTypeAssets {
  static const package = 'twogo_design_system';

  static const cafePath = 'assets/meals/cafe.png';
  static const almocoPath = 'assets/meals/almoco.png';
  static const jantarPath = 'assets/meals/jantar.png';

  static String pathFor(MealTypeAsset type) {
    switch (type) {
      case MealTypeAsset.cafe:
        return cafePath;
      case MealTypeAsset.almoco:
        return almocoPath;
      case MealTypeAsset.jantar:
        return jantarPath;
    }
  }

  /// Resolve from category (`CAFE`/`RESTAURANT`) + title/period text.
  static MealTypeAsset resolve({
    String? category,
    String? title,
    String? period,
  }) {
    final blob =
        '${category ?? ''} ${title ?? ''} ${period ?? ''}'.toLowerCase();
    if (blob.contains('café') ||
        blob.contains('cafe') ||
        blob.contains('manhã') ||
        blob.contains('manha') ||
        blob.contains('breakfast') ||
        blob.contains('CAFE'.toLowerCase())) {
      return MealTypeAsset.cafe;
    }
    if (blob.contains('jantar') ||
        blob.contains('dinner') ||
        blob.contains('noite')) {
      return MealTypeAsset.jantar;
    }
    return MealTypeAsset.almoco;
  }

  /// Generic meal-slot labels (unselected).
  static bool isGenericMealTitle(String? title) {
    final t = title?.trim().toLowerCase() ?? '';
    return t == 'café da manhã' ||
        t == 'cafe da manha' ||
        t == 'almoço' ||
        t == 'almoco' ||
        t == 'jantar' ||
        t == 'lanche' ||
        t == 'pausa';
  }
}
