import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_reviews/reviews.dart';

void main() {
  test('TwoGoReviewsModule initialization test', () {
    const module = TwoGoReviewsModule();
    expect(module, isNotNull);
  });
}
