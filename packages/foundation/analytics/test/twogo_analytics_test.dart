import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_analytics/twogo_analytics.dart';

void main() {
  test('TwoGoAnalytics initialization test', () {
    const instance = TwoGoAnalytics();
    expect(instance, isNotNull);
  });
}
