import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_config/twogo_config.dart';

void main() {
  test('ApiConfig initialization test', () {
    const config = ApiConfig();
    expect(config.baseUrl, isNotEmpty);
  });
}
