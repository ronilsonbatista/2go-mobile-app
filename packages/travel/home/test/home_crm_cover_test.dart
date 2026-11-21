import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_home/twogo_home.dart';

void main() {
  group('resolveHomeCrmCover', () {
    test('uses trip coverImageUrl when present', () {
      const trip = HomeTripSummary(
        id: 't1',
        destinationNames: ['Tokyo'],
        coverImageUrl: 'https://cdn.example/tokyo.jpg',
      );
      final cover = resolveHomeCrmCover(trip: trip);
      expect(cover.networkUrl, 'https://cdn.example/tokyo.jpg');
      expect(cover.hasImage, isTrue);
    });

    test('falls back to local Tóquio asset for Tokyo name', () {
      const trip = HomeTripSummary(
        id: 't1',
        destinationNames: ['Tokyo'],
      );
      final cover = resolveHomeCrmCover(trip: trip);
      expect(cover.networkUrl, isNull);
      expect(cover.assetPath, 'assets/destinations/toquio.jpg');
      expect(cover.hasImage, isTrue);
    });

    test('matches Home destinations catalog by alias', () {
      const trip = HomeTripSummary(
        id: 't1',
        destinationNames: ['Tokyo'],
      );
      const destinations = [
        HomeDestination(
          id: 'toquio',
          name: 'Tóquio',
          country: 'Japão',
          imageUrl: 'https://cdn.example/home-toquio.jpg',
          heroAssetPath: 'assets/destinations/toquio.jpg',
        ),
      ];
      final cover = resolveHomeCrmCover(
        trip: trip,
        destinations: destinations,
      );
      expect(cover.networkUrl, 'https://cdn.example/home-toquio.jpg');
      expect(cover.assetPath, 'assets/destinations/toquio.jpg');
    });
  });
}
