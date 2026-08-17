import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_design_system/design_system.dart';

void main() {
  test('Design system basic export test', () {
    expect(TwoGoColors.brandLime, isNotNull);
    expect(TwoGoSpacing.md, equals(16.0));
    expect(TwoGoRadius.medium, equals(8.0));
  });
}
