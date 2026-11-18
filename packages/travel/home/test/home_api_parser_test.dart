import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_home/twogo_home.dart';

void main() {
  group('HomeDestinationsParser', () {
    const parser = HomeDestinationsParser();

    test('reads data.items from raw Core envelope (not root items)', () {
      final destinations = parser.parse({
        'success': true,
        'timestamp': '2026-11-18T12:00:00.000Z',
        'items': [
          // Poison root-level items — must be ignored.
          {
            'id': 'root-poison',
            'name': 'Poison',
            'country': 'X',
            'imageUrl': 'https://cdn.example/poison.jpg',
            'sortOrder': 0,
            'active': true,
          },
        ],
        'data': {
          'items': [
            {
              'id': 'capadocia',
              'slug': 'capadocia',
              'name': 'Capadócia',
              'country': 'Turquia',
              'imageUrl': 'https://cdn.example/capadocia.jpg',
              'cardImageUrl': 'https://cdn.example/capadocia-card.jpg',
              'sortOrder': 2,
              'active': true,
            },
            {
              'id': 'rio-de-janeiro',
              'name': 'Rio de Janeiro',
              'country': 'Brasil',
              'imageUrl': 'https://cdn.example/rio.jpg',
              'sortOrder': 1,
              'active': true,
            },
            {
              'id': 'hidden',
              'name': 'Hidden',
              'country': 'X',
              'imageUrl': 'https://cdn.example/hidden.jpg',
              'sortOrder': 0,
              'active': false,
            },
          ],
        },
      });

      expect(destinations.map((d) => d.id), [
        'rio-de-janeiro',
        'capadocia',
      ]);
      expect(destinations.first.imageUrl, 'https://cdn.example/rio.jpg');
      expect(
        destinations.last.cardImageUrl,
        'https://cdn.example/capadocia-card.jpg',
      );
      expect(destinations, isNot(contains(predicate((HomeDestination d) {
        return d.id == 'root-poison' || d.id == 'hidden';
      }))));
    });

    test('parses unwrapped { items } after ApiEnvelopeInterceptor', () {
      final destinations = parser.parse({
        'items': [
          {
            'slug': 'nova-york',
            'name': 'Nova York',
            'country': 'EUA',
            'imageUrl': 'https://cdn.example/ny.jpg',
            'sortOrder': 0,
            'active': true,
          },
        ],
      });

      expect(destinations, hasLength(1));
      expect(destinations.single.id, 'nova-york');
      expect(destinations.single.hasRemoteHero, isTrue);
    });

    test('clampLimit enforces Core 1..50 and parse respects limit', () {
      expect(HomeDestinationsParser.clampLimit(null), 50);
      expect(HomeDestinationsParser.clampLimit(0), 1);
      expect(HomeDestinationsParser.clampLimit(-3), 1);
      expect(HomeDestinationsParser.clampLimit(1), 1);
      expect(HomeDestinationsParser.clampLimit(50), 50);
      expect(HomeDestinationsParser.clampLimit(99), 50);

      final items = List.generate(12, (i) {
        return {
          'id': 'd$i',
          'name': 'Dest $i',
          'country': 'BR',
          'imageUrl': 'https://cdn.example/$i.jpg',
          'sortOrder': i,
          'active': true,
        };
      });

      final limited = parser.parse({'items': items}, limit: 3);
      expect(limited, hasLength(3));
      expect(limited.map((d) => d.id), ['d0', 'd1', 'd2']);
    });
  });

  group('HomeProfileParser', () {
    const parser = HomeProfileParser();

    test('reads nested user.photoUrl null as initials (no photo)', () {
      final profile = parser.parse({
        'success': true,
        'data': {
          'user': {
            'id': 'usr_1',
            'displayName': 'Gustavo Vieira',
            'photoUrl': null,
          },
        },
        'timestamp': '2026-11-18T12:00:00.000Z',
      });

      expect(profile.isAuthenticated, isTrue);
      expect(profile.photoUrl, isNull);
      expect(profile.hasPhoto, isFalse);
      expect(profile.displayName, 'Gustavo Vieira');
      expect(profile.initials, 'GV');
    });

    test('reads nested user.photoUrl when present', () {
      final profile = parser.parse({
        'user': {
          'id': 'usr_2',
          'displayName': 'Ana',
          'photoUrl': 'https://cdn.example/ana.jpg',
        },
      });

      expect(profile.hasPhoto, isTrue);
      expect(profile.photoUrl, 'https://cdn.example/ana.jpg');
      expect(profile.initials, 'AN');
    });

    test('empty photoUrl string is treated as no photo', () {
      final profile = parser.parse({
        'user': {
          'id': 'usr_3',
          'displayName': 'Bo',
          'photoUrl': '   ',
        },
      });

      expect(profile.hasPhoto, isFalse);
      expect(profile.photoUrl, isNull);
    });
  });

  group('RemoteHomeContentRepository', () {
    test('GET /home/destinations sends clamped limit query', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://core.test'));
      Map<String, dynamic>? query;

      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            query = Map<String, dynamic>.from(options.queryParameters);
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'items': [
                    {
                      'id': 'capadocia',
                      'name': 'Capadócia',
                      'country': 'Turquia',
                      'imageUrl': 'https://cdn.example/c.jpg',
                      'sortOrder': 0,
                      'active': true,
                    },
                  ],
                },
              ),
            );
          },
        ),
      );

      final repo = RemoteHomeContentRepository(dio: dio, destinationsLimit: 99);
      final items = await repo.fetchDestinations();

      expect(query?['limit'], 50);
      expect(items, hasLength(1));
      expect(items.single.id, 'capadocia');
    });

    test('resolveProfile maps null photoUrl from /users/me', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://core.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.path, '/users/me');
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'user': {
                    'id': 'usr_1',
                    'displayName': 'Gustavo Vieira',
                    'photoUrl': null,
                  },
                },
              ),
            );
          },
        ),
      );

      final repo = RemoteHomeContentRepository(dio: dio);
      final profile = await repo.resolveProfile(
        isAuthenticated: true,
        userId: 'gustavo@2go.app',
      );

      expect(profile.hasPhoto, isFalse);
      expect(profile.initials, 'GV');
    });
  });

  group('FallbackHomeContentRepository', () {
    test('falls back to stub when remote fails', () async {
      final repo = FallbackHomeContentRepository(
        remote: _ThrowingHomeRepository(),
        fallback: LocalHomeContentRepository(forceInitialsOnly: true),
      );

      final destinations = await repo.fetchDestinations();
      expect(destinations.length, greaterThanOrEqualTo(10));

      final profile = await repo.resolveProfile(
        isAuthenticated: true,
        userId: 'ana@2go.app',
      );
      expect(profile.hasPhoto, isFalse);
      expect(profile.initials, 'AN');
    });
  });
}

class _ThrowingHomeRepository implements HomeContentRepository {
  @override
  Future<List<HomeDestination>> fetchDestinations() {
    return Future.error(Exception('staging down'));
  }

  @override
  Future<HomeProfile> resolveProfile({
    required bool isAuthenticated,
    String? userId,
  }) {
    return Future.error(Exception('staging down'));
  }
}
