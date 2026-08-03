import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_sync/twogo_sync.dart';

void main() {
  test('TwoGoSync initialization test', () {
    const instance = TwoGoSync();
    expect(instance, isNotNull);
  });
}
