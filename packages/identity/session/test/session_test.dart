import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_session/session.dart';

void main() {
  test('TwoGoSessionModule initialization test', () {
    const module = TwoGoSessionModule();
    expect(module, isNotNull);
  });
}
