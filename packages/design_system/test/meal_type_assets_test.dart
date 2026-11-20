import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_design_system/design_system.dart';

void main() {
  test('resolves café / almoço / jantar from title and category', () {
    expect(
      MealTypeAssets.resolve(title: 'Café da manhã', category: 'CAFE'),
      MealTypeAsset.cafe,
    );
    expect(
      MealTypeAssets.resolve(title: 'Almoço', category: 'RESTAURANT'),
      MealTypeAsset.almoco,
    );
    expect(
      MealTypeAssets.resolve(title: 'Jantar', period: 'Noite'),
      MealTypeAsset.jantar,
    );
  });

  test('detects generic meal slot titles', () {
    expect(MealTypeAssets.isGenericMealTitle('Café da manhã'), isTrue);
    expect(MealTypeAssets.isGenericMealTitle('Ombre Rosse'), isFalse);
  });
}
