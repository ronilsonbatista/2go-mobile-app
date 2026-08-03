import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_networking/twogo_networking.dart';

void main() {
  test('TwoGoNetworking initialization test', () {
    const instance = TwoGoNetworking();
    expect(instance, isNotNull);
  });
}
