import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_feature_flags/twogo_feature_flags.dart';

void main() {
  test('TwoGoFeatureFlags initialization test', () {
    const instance = TwoGoFeatureFlags();
    expect(instance, isNotNull);
  });
}
