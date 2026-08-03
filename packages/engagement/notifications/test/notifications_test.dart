import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_notifications/notifications.dart';

void main() {
  test('TwoGoNotificationsModule initialization test', () {
    const module = TwoGoNotificationsModule();
    expect(module, isNotNull);
  });
}
