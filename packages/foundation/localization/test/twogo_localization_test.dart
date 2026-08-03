import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_localization/twogo_localization.dart';

void main() {
  test('TwoGoLocalization initialization test', () {
    const instance = TwoGoLocalization();
    expect(instance, isNotNull);
  });
}
