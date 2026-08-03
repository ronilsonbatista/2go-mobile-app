import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_storage/twogo_storage.dart';

void main() {
  test('TwoGoStorage initialization test', () {
    const instance = TwoGoStorage();
    expect(instance, isNotNull);
  });
}
