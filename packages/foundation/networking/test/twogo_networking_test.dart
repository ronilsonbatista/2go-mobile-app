import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_config/twogo_config.dart';
import 'package:twogo_networking/twogo_networking.dart';
import 'package:twogo_test_support/twogo_test_support.dart';

void main() {
  test('TwoGoNetworking initialization test', () {
    final client = DioClientFactory.create(
      config: const ApiConfig(),
      tokenStorage: InMemoryTokenStorage(),
    );
    expect(client, isNotNull);
  });
}
