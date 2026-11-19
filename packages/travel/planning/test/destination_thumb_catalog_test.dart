import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_planning/twogo_planning.dart';

void main() {
  group('DestinationThumbCatalog', () {
    test('maps Roma / Paris / Tóquio to curated monument assets', () {
      expect(
        DestinationThumbCatalog.assetForName('Roma'),
        'assets/destination_thumbs/roma.jpg',
      );
      expect(
        DestinationThumbCatalog.assetForName('Paris'),
        'assets/destination_thumbs/paris.jpg',
      );
      expect(
        DestinationThumbCatalog.assetForName('Tóquio'),
        'assets/destination_thumbs/toquio.jpg',
      );
      expect(
        DestinationThumbCatalog.assetForName('Tokyo'),
        'assets/destination_thumbs/toquio.jpg',
      );
    });

    test('returns null for unknown places', () {
      expect(DestinationThumbCatalog.assetForName('Atlantis'), isNull);
      expect(DestinationThumbCatalog.assetForName(null), isNull);
      expect(DestinationThumbCatalog.assetForName('  '), isNull);
    });
  });
}
