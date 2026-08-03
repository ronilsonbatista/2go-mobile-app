import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_chat/chat.dart';

void main() {
  test('TwoGoChatModule initialization test', () {
    const module = TwoGoChatModule();
    expect(module, isNotNull);
  });
}
