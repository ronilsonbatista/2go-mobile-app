import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_documents/documents.dart';

void main() {
  test('TwoGoDocumentsModule initialization test', () {
    const module = TwoGoDocumentsModule();
    expect(module, isNotNull);
  });
}
