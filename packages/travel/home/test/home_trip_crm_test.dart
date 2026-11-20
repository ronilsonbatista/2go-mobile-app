import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_design_system/design_system.dart';
import 'package:twogo_home/twogo_home.dart';
import 'package:twogo_security/twogo_security.dart';
import 'package:twogo_session/twogo_session.dart';

class _MemoryTokenStorage implements TokenStorage {
  AuthTokens? _tokens;

  @override
  Future<void> clearTokens() async => _tokens = null;

  @override
  Future<AuthTokens?> readTokens() async => _tokens;

  @override
  Future<void> saveTokens(AuthTokens tokens) async => _tokens = tokens;
}

class _FakeCrmRepo implements HomeContentRepository {
  _FakeCrmRepo({
    required this.destinations,
    required this.profile,
    this.crm = HomeCrmSnapshot.empty,
  });

  final List<HomeDestination> destinations;
  final HomeProfile profile;
  final HomeCrmSnapshot crm;

  @override
  Future<List<HomeDestination>> fetchDestinations() async => destinations;

  @override
  Future<HomeProfile> resolveProfile({
    required bool isAuthenticated,
    String? userId,
  }) async {
    if (!isAuthenticated) return HomeProfile.guest();
    return profile;
  }

  @override
  Future<HomeCrmSnapshot> fetchCrmSnapshot({
    required bool isAuthenticated,
    String? userId,
  }) async {
    if (!isAuthenticated) return HomeCrmSnapshot.empty;
    return crm;
  }
}

Map<String, dynamic> _sampleTripJson({
  List<Map<String, dynamic>>? destinations,
  List<Map<String, dynamic>>? tips,
  int tipCountRoma = 3,
}) {
  final dests = destinations ??
      [
        {
          'name': 'Roma',
          'country': 'Itália',
          'order': 0,
          'destinationKey': 'roma',
          'coverImageUrl': 'https://cdn.example/roma.jpg',
        },
        {
          'name': 'Paris',
          'country': 'França',
          'order': 1,
          'destinationKey': 'paris',
        },
      ];

  final tipList = tips ??
      List.generate(tipCountRoma, (i) {
        return {
          'id': 'roma-tip-$i',
          'destinationKey': 'roma',
          'destinationName': 'Roma',
          'title': 'Tip Roma $i',
          'body': 'Body Roma $i — useful advice for travelers.',
          'sortOrder': i,
          'source': 'PLACEHOLDER',
        };
      });

  return {
    'success': true,
    'timestamp': '2026-11-20T12:00:00.000Z',
    'data': {
      'trip': {
        'id': 'trip-1',
        'title': 'Viagem para Roma & Paris',
        'destinations': dests,
        'coverImageUrl': 'https://cdn.example/roma.jpg',
        'startDate': '2026-07-25',
        'endDate': '2026-07-28',
        'arrivalDateTime': '2026-07-25T14:00:00.000Z',
        'days': [
          {
            'id': 'd1',
            'dayNumber': 1,
            'date': '2026-07-25',
            'destination': 'Roma',
            'title': 'Chegada',
            'itemCount': 4,
          },
          {
            'id': 'd2',
            'dayNumber': 2,
            'date': '2026-07-26',
            'destination': 'Paris',
            'title': 'Louvre',
            'itemCount': 5,
          },
        ],
        'premiumUnlocked': true,
        'status': 'ACTIVE',
        'tips': tipList,
      },
    },
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HomeTripDestinationLabel', () {
    test('formats 1 / 2 / 3+ cities from Core names only', () {
      expect(HomeTripDestinationLabel.format(['Roma']), 'Roma');
      expect(
        HomeTripDestinationLabel.format(['Roma', 'Paris']),
        'Roma e Paris',
      );
      expect(
        HomeTripDestinationLabel.format(['Roma', 'Paris', 'Lisboa', 'Londres']),
        'Roma e Paris e mais 2',
      );
      expect(
        HomeTripDestinationLabel.stackedLines(['Roma', 'Paris']),
        ['Roma', 'e Paris'],
      );
    });
  });

  group('HomeTipsParser', () {
    const parser = HomeTipsParser();

    test('caps at 3 tips per destinationKey', () {
      final tips = parser.parse({
        'success': true,
        'data': {
          'items': [
            for (var i = 0; i < 5; i++)
              {
                'id': 'r$i',
                'destinationKey': 'roma',
                'title': 'T$i',
                'body': 'B$i',
                'sortOrder': i,
              },
            for (var i = 0; i < 4; i++)
              {
                'id': 'p$i',
                'destinationKey': 'paris',
                'title': 'P$i',
                'body': 'PB$i',
                'sortOrder': i,
              },
          ],
        },
      });

      expect(tips.where((t) => t.destinationKey == 'roma'), hasLength(3));
      expect(tips.where((t) => t.destinationKey == 'paris'), hasLength(3));
      expect(tips.firstWhere((t) => t.destinationKey == 'roma').title, 'T0');
    });
  });

  group('HomeTripSummaryParser', () {
    const parser = HomeTripSummaryParser();

    test('parses GET /home/trip envelope with destinations and days', () {
      final trip = parser.parseHomeTripResponse(_sampleTripJson());
      expect(trip, isNotNull);
      expect(trip!.id, 'trip-1');
      expect(trip.destinationNames, ['Roma', 'Paris']);
      expect(trip.destinationLabel, 'Roma e Paris');
      expect(trip.days, hasLength(2));
      expect(trip.days.first.destination, 'Roma');
      expect(trip.days.first.itemCount, 4);
      expect(trip.countdownTarget, DateTime.parse('2026-07-25T14:00:00.000Z'));
      expect(trip.tips, hasLength(3));
      expect(trip.premiumUnlocked, isTrue);
    });

    test('trip null → discovery (null summary)', () {
      final trip = parser.parseHomeTripResponse({
        'success': true,
        'data': {'trip': null},
      });
      expect(trip, isNull);
    });

    test('parses unwrapped data after ApiEnvelopeInterceptor', () {
      // Interceptor replaces body with inner `data` → `{ trip: {...} }`.
      final trip = parser.parseHomeTripResponse({
        'trip': {
          'id': 'trip-2',
          'destinations': [
            {'name': 'Lisboa', 'destinationKey': 'lisboa', 'order': 0},
          ],
          'startDate': '2026-08-01',
          'endDate': '2026-08-05',
          'days': const <dynamic>[],
          'tips': const <dynamic>[],
          'premiumUnlocked': true,
        },
      });
      expect(trip, isNotNull);
      expect(trip!.destinationNames, ['Lisboa']);
      expect(trip.destinationLabel, 'Lisboa');
    });

    test('never invents cities when destinations empty and no fallback', () {
      final trip = parser.parseHomeTripResponse({
        'data': {
          'trip': {
            'id': 'x',
            'destinations': <dynamic>[],
            'premiumUnlocked': true,
          },
        },
      });
      expect(trip, isNull);
    });
  });

  group('HomeCrmRemote', () {
    test('loads trip from GET /home/trip', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.path, '/home/trip');
            handler.resolve(
              Response(
                requestOptions: options,
                data: _sampleTripJson(),
                statusCode: 200,
              ),
            );
          },
        ),
      );

      final remote = HomeCrmRemote(dio: dio);
      final snap = await remote.fetch(isAuthenticated: true);
      expect(snap.hasPaidTrip, isTrue);
      expect(snap.trip!.destinationNames, ['Roma', 'Paris']);
      expect(snap.tips, hasLength(3));
    });

    test('404 soft-empty for staging before deploy', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                response: Response(requestOptions: options, statusCode: 404),
                type: DioExceptionType.badResponse,
              ),
            );
          },
        ),
      );
      final snap = await HomeCrmRemote(dio: dio).fetch(isAuthenticated: true);
      expect(snap.hasPaidTrip, isFalse);
    });
  });

  group('HomeCubit CRM shell', () {
    test('paid trip → crm shell; null trip → discovery', () async {
      final trip = const HomeTripSummaryParser().parseHomeTripResponse(
        _sampleTripJson(),
      )!;

      final withTrip = HomeCubit(
        repository: _FakeCrmRepo(
          destinations: [
            const HomeDestination(
              id: 'capadocia',
              name: 'Capadócia',
              country: 'Turquia',
            ),
          ],
          profile: HomeProfile.authenticated(displayName: 'Gustavo Vieira'),
          crm: HomeCrmSnapshot(trip: trip, tips: trip.tips),
        ),
        autoAdvance: false,
      );
      await withTrip.load(isAuthenticated: true, userId: 'u1');
      expect(withTrip.state.shellMode, HomeShellMode.crm);
      expect(withTrip.state.crm.hasPaidTrip, isTrue);
      await withTrip.close();

      final noTrip = HomeCubit(
        repository: _FakeCrmRepo(
          destinations: [
            const HomeDestination(
              id: 'capadocia',
              name: 'Capadócia',
              country: 'Turquia',
            ),
          ],
          profile: HomeProfile.authenticated(displayName: 'Gustavo Vieira'),
        ),
        autoAdvance: false,
      );
      await noTrip.load(isAuthenticated: true, userId: 'u1');
      expect(noTrip.state.shellMode, HomeShellMode.discovery);
      await noTrip.close();
    });
  });

  group('HomeView CRM widgets', () {
    testWidgets('shows próxima viagem and tips from Core snapshot', (
      tester,
    ) async {
      LocalHomeContentRepository.usePackageAssetPrefix = false;
      addTearDown(() {
        LocalHomeContentRepository.usePackageAssetPrefix = true;
      });

      final trip = const HomeTripSummaryParser().parseHomeTripResponse(
        _sampleTripJson(),
      )!;
      final session = SessionCubit(tokenStorage: _MemoryTokenStorage());
      session.onAuthenticated(
        const AuthTokens(accessToken: 'a', refreshToken: 'r'),
        'gustavo@2go.com',
      );
      final homeCubit = HomeCubit(
        repository: _FakeCrmRepo(
          destinations: [
            const HomeDestination(
              id: 'rio',
              name: 'Rio de Janeiro',
              country: 'Brasil',
              cardAssetPath: 'assets/destinations/rio-de-janeiro-card.jpg',
              heroAssetPath: 'assets/destinations/rio-de-janeiro.jpg',
            ),
          ],
          profile: HomeProfile.authenticated(displayName: 'Gustavo Vieira'),
          crm: HomeCrmSnapshot(trip: trip, tips: trip.tips),
        ),
        autoAdvance: false,
      );
      addTearDown(homeCubit.close);
      addTearDown(session.close);

      await homeCubit.load(isAuthenticated: true, userId: 'gustavo@2go.com');

      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(390, 844)),
          child: MaterialApp(
            theme: TwoGoTheme.light,
            home: MultiBlocProvider(
              providers: [
                BlocProvider<SessionCubit>.value(value: session),
                BlocProvider<HomeCubit>.value(value: homeCubit),
              ],
              child: HomeView(
                onCreateItinerary: () {},
                onAccessItineraries: () {},
                onProfileTap: () {},
                now: () => DateTime.utc(2026, 7, 1, 12),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.textContaining('Olá, Gustavo'), findsOneWidget);
      expect(find.textContaining('Próxima viagem'), findsOneWidget);
      // Stacked overlay for 2 cities (Home-3/7): "Roma" + "e Paris".
      expect(find.text('Roma'), findsWidgets);
      expect(find.text('e Paris'), findsOneWidget);
      expect(find.textContaining('Dicas para você'), findsOneWidget);
      expect(find.text('Tip Roma 0'), findsOneWidget);
      expect(find.textContaining('Dia 1'), findsOneWidget);
      expect(find.text('Criar novo roteiro'), findsOneWidget);
    });
  });
}
