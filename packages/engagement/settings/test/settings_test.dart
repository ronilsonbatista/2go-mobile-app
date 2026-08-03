import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_settings/settings.dart';

void main() {
  test('TwoGoSettingsModule initialization test', () {
    const module = TwoGoSettingsModule();
    expect(module, isNotNull);
  });
}
