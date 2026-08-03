import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_design_system/design_system.dart';

void main() {
  test('Design system tokens test', () {
    expect(TwoGoColors.primary, isNotNull);
    expect(TwoGoSpacing.md, equals(16.0));
  });
}
