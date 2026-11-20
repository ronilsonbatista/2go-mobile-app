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

class _Repo implements HomeContentRepository {
  _Repo(this.crm);

  final HomeCrmSnapshot crm;

  @override
  Future<List<HomeDestination>> fetchDestinations() async => [
        const HomeDestination(
          id: 'rio',
          name: 'Rio de Janeiro',
          country: 'Brasil',
          heroAssetPath: 'assets/destinations/rio-de-janeiro.jpg',
          cardAssetPath: 'assets/destinations/rio-de-janeiro-card.jpg',
        ),
      ];

  @override
  Future<HomeProfile> resolveProfile({
    required bool isAuthenticated,
    String? userId,
  }) async =>
      HomeProfile.authenticated(displayName: 'Gustavo Vieira');

  @override
  Future<HomeCrmSnapshot> fetchCrmSnapshot({
    required bool isAuthenticated,
    String? userId,
  }) async =>
      crm;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('CRM home renders Core trip + tips (no hardcode cities)', (
    tester,
  ) async {
    LocalHomeContentRepository.usePackageAssetPrefix = false;
    addTearDown(() {
      LocalHomeContentRepository.usePackageAssetPrefix = true;
    });

    const parser = HomeTripSummaryParser();
    final trip = parser.parseHomeTripResponse({
      'trip': {
        'id': 'trip-1',
        'title': 'Viagem',
        'destinations': [
          {'name': 'Roma', 'destinationKey': 'roma', 'order': 0},
          {'name': 'Paris', 'destinationKey': 'paris', 'order': 1},
        ],
        'coverImageUrl': null,
        'startDate': '2026-07-25',
        'endDate': '2026-07-28',
        'arrivalDateTime': '2026-07-25T14:00:00.000Z',
        'days': [
          {
            'id': 'd1',
            'dayNumber': 1,
            'destination': 'Roma',
            'title': 'Chegada',
            'itemCount': 4,
          },
        ],
        'premiumUnlocked': true,
        'tips': [
          {
            'id': 't1',
            'destinationKey': 'roma',
            'title': 'Diversifique as formas de pagamento',
            'body':
                'Leve uma combinação de dinheiro em espécie e cartão internacional.',
            'sortOrder': 0,
            'source': 'PLACEHOLDER',
          },
        ],
      },
    })!;

    final session = SessionCubit(tokenStorage: _MemoryTokenStorage());
    session.onAuthenticated(
      const AuthTokens(accessToken: 'a', refreshToken: 'r'),
      'gustavo@2go.com',
    );
    final homeCubit = HomeCubit(
      repository: _Repo(HomeCrmSnapshot(trip: trip, tips: trip.tips)),
      autoAdvance: false,
    );
    addTearDown(homeCubit.close);
    addTearDown(session.close);
    await homeCubit.load(isAuthenticated: true);

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

    expect(find.textContaining('Próxima viagem'), findsOneWidget);
    expect(find.text('Roma'), findsWidgets);
    expect(find.text('e Paris'), findsOneWidget);
    expect(find.textContaining('Dicas para você'), findsOneWidget);
    expect(find.text('Diversifique as formas de pagamento'), findsOneWidget);
    expect(find.textContaining('Dia 1 · Roma'), findsOneWidget);
  });
}
